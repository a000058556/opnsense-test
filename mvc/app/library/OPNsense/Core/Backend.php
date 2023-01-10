<?php

/*
 * Copyright (C) 2015 Deciso B.V.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

namespace OPNsense\Core;

use OPNsense\Phalcon\Logger\Logger;
use Phalcon\Logger\Adapter\Syslog;
use Phalcon\Logger\Formatter\Line;

/**
 * Class Backend
 * @package OPNsense\Core
 */
class Backend
{
    /**
     * @var string location of configd socket
     */
    private $configdSocket = '/var/run/configd.socket';

    /**
     * init Backend component
     */
    public function __construct()
    {
    }

    /**
     * get system logger
     * @param string $ident syslog identifier
     * @return Syslog log handler
     */
    protected function getLogger($ident = 'configd.py')
    {
        $formatter = new Line('%message%');
        $adapter = new Syslog(
            $ident,
            [
                'option'   => LOG_PID,
                'facility' => LOG_LOCAL4,
            ]
        );
        $adapter->setFormatter($formatter);
        $logger = new Logger(
            'messages',
            [
                'main' => $adapter
            ]
        );

        return $logger;
    }

    /**
     * send event to backend
     * @param string $event event string
     * @param bool $detach detach process
     * @param int $timeout timeout in seconds
     * @param int $connect_timeout connect timeout in seconds
     * @return string
     * @throws \Exception
     */
    public function configdRun($event, $detach = false, $timeout = 120, $connect_timeout = 10)
    {
        // 範例: $event = filter rule stats / interface show traffic
        $endOfStream = chr(0) . chr(0) . chr(0); // 將 ASCII 碼轉換為字串符
        $errorOfStream = 'Execute error';
        $poll_timeout = 2; // poll timeout interval

        // wait until socket exist for a maximum of $connect_timeout
        $timeout_wait = $connect_timeout;
        $errorMessage = "";
        // configdSocket = /var/run/configd.socket
        while ( 
            // 當找不到configdSocket檔案 或 無法打開configdSocket檔案時
            !file_exists($this->configdSocket) ||
            // stream_socket_client()用於打開Internet或Unix域套接字(範例 unix:///var/run/configd.socket)
            // 被呼叫的內容在: /opnsense/service/conf/actions.d 中
            // 例如: configdRun("filter rule stats") 就是呼叫 /opnsense/service/conf/actions.d/actions_filter.conf > [rule.stats]
            ($stream = @stream_socket_client('unix://' . $this->configdSocket, $errorNumber, $errorMessage, $poll_timeout)) === false
        ) {
            // 若找不到configd.socket檔
            sleep(1);
            $timeout_wait -= 1;
            // 當嘗試時間<=0時
            // 回傳null ，並送出錯誤訊息
            if ($timeout_wait <= 0) {
                if (file_exists($this->configdSocket)) {
                    $this->getLogger()->error("Failed to connect to configd socket: $errorMessage while executing " . $event);
                    return null;
                } else {
                    $this->getLogger()->error("failed waiting for configd (doesn't seem to be running)");
                }
                return null;
            }
        }

        $resp = '';

        // 設置讀取資料的超時時間
        stream_set_timeout($stream, $poll_timeout);
        // send command
        // $detach = true 執行 fwrite($stream, '&' . $event);
        // $detach = false 則執行 fwrite($stream, $event);
        // 範例: $event = "netflow aggregate metadata json"
        // 範例: $event = filter rule stats
        // 範例: $event = interface show traffic
        // $stream = @stream_socket_client('unix://' . $this->configdSocket, $errorNumber, $errorMessage, $poll_timeout)
        if ($detach) {
            // fwrite() 把 string 的內容寫入文件。成功時返回寫入的字符數，出現錯誤時則返回 false。
            fwrite($stream, '&' . $event);
        } else {
            fwrite($stream, $event);
        }

        // read response data
        $starttime = time(); // 取得開始時間
        while (true) {
            // stream_get_contents()在已打開的流資源上操作並返回字符串中的剩餘內容
            // stream_get_contents(resource $stream, ?int $length = null, int $offset = -1): string|false
            // $stream = 資源流
            // $length = 要讀取的最大字節數。默認為null(讀取全部)
            // $offset = 讀取前尋找指定的偏移量。如果此數字是負數，則不會發生查找，並且從當前位置開始讀取
            $resp = $resp . stream_get_contents($stream);

            // $errorOfStream = 'Execute error';
            if (strpos($resp, $endOfStream) !== false) {
                // end of stream detected, exit
                break;
            }

            // handle timeouts
            // 當現在時間減去開始時間>時間限時
            if ((time() - $starttime) > $timeout) {
                // 傳送錯誤訊息
                $this->getLogger()->error("Timeout (" . $timeout . ") executing : " . $event);
                return null;
            } elseif (feof($stream)) {
                // feof() 函數檢測是否已到達文件末尾 (eof)。
                // 如果文件指針到了 EOF 或者出錯時(中途段開鏈接)則返回 TRUE，否則返回一個錯誤（包括 socket 超時），其它情況則返回 FALSE。
                $this->getLogger()->error("Configd disconnected while executing : " . $event);
                return null;
            }
        }

        if (
            // 取$resp字串長度比較$errorOfStream字串長度
            strlen($resp) >= strlen($errorOfStream) &&
            // 從0開始取$errorOfStream的字串長度 若 = $errorOfStream
            // 回傳null
            substr($resp, 0, strlen($errorOfStream)) == $errorOfStream
        ) {
            return null;
        }

        return str_replace($endOfStream, '', $resp);
        // str_replace(find,replace,string,count)
        //  find	必需。要查找的值。 $endOfStream = chr(0) . chr(0) . chr(0);
        //  replace	必需。替換find中的值的值。
        //  string	必需。被搜索的字符串。
        //  count	可選。一個變量，對替換數進行計數。
    }

    /**
     * send event to backend using command parameter list (which will be quoted for proper handling)
     * @param string $event event string
     * @param array $params list of parameters to send with command
     * @param bool $detach detach process
     * @param int $timeout timeout in seconds
     * @param int $connect_timeout connect timeout in seconds
     * @return string
     * @throws \Exception
     */
    public function configdpRun($event, $params = array(), $detach = false, $timeout = 120, $connect_timeout = 10)
    {
        if (!is_array($params)) {
            /* just in case there's only one parameter */
            $params = array($params);
        }

        foreach ($params as $param) {
            $event .= ' ' . escapeshellarg($param);
        }

        return $this->configdRun($event, $detach, $timeout, $connect_timeout);
    }

    /**
     * check configd socket for last restart, return 0 socket not present.
     * @return int last restart timestamp
     */
    public function getLastRestart()
    {
        if (file_exists($this->configdSocket)) {
            return filemtime($this->configdSocket);
        } else {
            return 0;
        }
    }
}
