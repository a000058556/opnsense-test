#!/usr/local/bin/python3

"""
    Copyright (c) 2019 Ad Schellevis <ad@opnsense.org>
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
    AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
    OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.

"""

import fcntl
import os
import time
import ujson
import sys
import subprocess

# rate limit pfctl calls, request every X seconds
RATE_LIMIT_S = 60

if __name__ == '__main__':
    # 建立接收資料的字典
    results = dict()
    cache_filename = '/tmp/cache_filter_rulestats.json'
    # os.stat(路徑) 方法將給定的路徑上，執行系統stat調用。
    # 回傳值:
    # st_mode: inode 保護模式
    # st_ino: inode 節點號。
    # st_dev: inode 駐留的設備。
    # st_nlink: inode 的鏈接數。
    # st_uid:所有者的用戶ID。
    # st_gid:所有者的組ID。
    # st_size:普通文件以字節為單位的大小；包含等待某些特殊文件的數據。
    # st_atime:上次訪問的時間。
    # st_mtime:最後一次修改的時間。
    # st_ctime:由操作系統報告的"ctime"。在某些系統上（如Unix）是最新的元數據更改的時間，在其它系統上（如Windows）是創建時間。
    
    # os.path.isfile() 檢查檔案是否存在，是的話回傳 True，反之回傳 False
    fstat = os.stat(cache_filename) if os.path.isfile(cache_filename) else None

    # 打開文件用於讀寫('a+')。
    # 若文件已存在，文件指針會放在文件的"結尾"。文件打開時會是追加模式。
    # 若文件不存在，創建新文件用於讀寫。
    fhandle = open(cache_filename, 'a+')
    try:
        fhandle.seek(0)
        # fileObject . seek ( offset [, whence ])
        # offset -- 開始的偏移量，也就是代表需要移動偏移的字節數。 0 = 指標移到開頭
        # whence：可選，默認值為0。給offset參數一個定義，表示要從哪個位置開始偏移；
        #         0代表從文件開頭開始算起，1代表從當前位置開始算起，2代表從文件末尾算起。
        # 返回值: 成功返回新的文件位置，失敗則函數返回-1。
        results = ujson.loads(fhandle.read())
        print('---------讀取檔案results----------')
        print(results)
        # fileObject.read([size]); 從文件讀取指定的字節數-1表示讀取整個文件。
        # size -- 從文件中讀取的字節數，默認為-1

        # ujson.loads(str) 將JSON str 轉換為字典對象
    except ValueError:
        # 若錯誤返回空字典
        results = dict()

    # 若沒有檔案 or 現在時間-最後一次修改的時間 > RATE_LIMIT_S(60) or 字典總長度 == 0
    # len(字典) = 計算字典的總長度(鍵值對總數)
    if fstat is None or (time.time() - fstat.st_mtime) > RATE_LIMIT_S or len(results) == 0:
        # 若字典總長度 == 0 ， 檔案鎖定中尚未取得資料
        if len(results) == 0:
            # lock blocking, nothing to return yet
            # flock(f, operation):給文件加鎖
            # f : 要被加鎖的檔案
            # operation : LOCK_EX 排他鎖:除加鎖進程外其他進程沒有對已加鎖文件讀寫訪問權限。
            fcntl.flock(fhandle, fcntl.LOCK_EX)
        else:
            try:
                # LOCK_NB 非阻塞鎖:此參數為，函數不能獲得文件鎖就立即返回，直接 raise OSError。
                fcntl.flock(fhandle, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except IOError:
                # already locked, return previous content
                print (ujson.dumps(results)) # 將dict類型的數據轉換成str
                sys.exit(0) # 無錯誤退出

        results = dict() # 重置results內容
        print('---------重置results內容----------')
        print(results)
        hex_digits = set("0123456789abcdef") # 建立驗證用集合
        # subprocess.run() 執行外部命令，指令以字串形式帶入 
        # 對Packet Filter下指令(man pfctl 可以看指令手冊)
        # pfctl -sr 顯示當前的過濾規則
        # 當與 -v 一起使用時，會顯示每個規則的統計信息（評估數、數據包和字節數）。
        # subprocess.run(args, *, stdin=None, input=None, stdout=None, stderr=None, shell=False, timeout=None, check=False, encoding=None, errors=None)
        # capture_output設為true時，stdout 和stderr 將會被捕獲
        # 子進程的：stdin(標準輸入)、stdout(標準輸出)、stderr(錯誤)
        # 若stdout(標準輸出)、stderr(錯誤)是用 text=True 來運行的，如果未有捕獲，則為None。
        sp = subprocess.run(['/sbin/pfctl', '-sr', '-v'], capture_output=True, text=True)
        stats = dict()
        prev_line = ''
        # 將sp.stdout取得的資料以換行(/n)做切割放入rline
        for rline in sp.stdout.split('\n') + []:
            print('---------載入順序----------')
            print(rline)
            # .strip()將單行的資料去掉開頭/結尾的空格
            # 範例: line = [ Evaluations: 37978     Packets: 37352     Bytes: 2751823     States: 0     ]
            line = rline.strip()
            print('---------載入並.strip()後----------')
            print(line)
            # 當單行資料長度==0 或 開頭不是'['時
            if len(line) == 0 or line[0] != '[':
                # 當prev_line中有label時 (-1 等於沒找到)
                if prev_line.find(' label ') > -1:
                print('---------prev_line內容----------')
                print(prev_line)
                    # lbl = prev_linem用label切開後，取最後一筆資料。
                    lbl = prev_line.split(' label ')[-1]
                    # count('"')返回字符串在字符串中出現的次數
                    # 當字符"出現2次或以上時
                    if lbl.count('"') >= 2:
                        # 將lbl以('"') 切割 取地[1]位放入 rule_md5 (放入範例: 02f4bab031b57d1e30553ce08e0ec131)
                        rule_md5 = lbl.split('"')[1]
                        print ("***********rule_mb5***********")
                        print (rule_md5)
                        print ("***********此時的results***********")
                        print (results)
                        # 若rule_md5字數 == 32 並確認rule_md5內的元素都包含在hex_digits中
                        # set.issubset(set)用于判断集合的所有元素是否都包含在指定集合中
                        if len(rule_md5) == 32 and set(rule_md5).issubset(hex_digits):
                            # 若rule_md5 在 results中(第一次為ipv4 第二次進來會是ipv6)
                            if rule_md5 in results:
                                # aggregate raw pf rules (a single rule in out ruleset could be expanded)
                                # 第一次的內容: 
                                # results = {"02f4bab031b57d1e30553ce08e0ec131":{'pf_rules': 1, 'evaluations': 5063, 'packets': 35, 'bytes': 3674, 'states': 0}}
                                # stats = {'pf_rules': 1, 'evaluations': 5063, 'packets': 35, 'bytes': 3674, 'states': 0}
                                for key in stats:
                                    print ("***********in results***********")
                                    print('///////////////要被加的stats////////////////')
                                    print(stats)
                                    # 如果stats的參數(pf_rules、evaluations等) 有 在results[rule_md5]中
                                    if key in results[rule_md5]:
                                        if key == 'pf_rules':
                                            # pf_rules參數+1
                                            results[rule_md5][key] += 1
                                        else:
                                            # 相加參數
                                            results[rule_md5][key] += stats[key]
                                    # 如果stats的參數(pf_rules、evaluations等) 沒 在results[rule_md5]中
                                    else:
                                        results[rule_md5][key] = stats[key]
                                print('++++++++++++++label相加+++++++++++++++')
                                print(results)
                            else:
                                print ("***********not in results***********")
                                # 若rule_md5 沒在 results中
                                # 在results字典中新建{key(rule_md5) : stats(dict())}
                                # 第一次進來的rule_md5會是這樣 {"02f4bab031b57d1e30553ce08e0ec131":{'pf_rules': 1}}
                                results[rule_md5] = stats
                                print('++++++++++++++新label+++++++++++++++')
                                print(results)
                # reset for next rule 為下一個規則重設
                prev_line = line
                stats = {'pf_rules': 1}
            # 當開頭='[' and line中有Evaluations字串時
            # 當還沒觸發if len(line) == 0 or line[0] != '[': 前，進到這裡的資料不會被回傳(一直覆寫)。
            elif line[0] == '['  and line.find('Evaluations') > 0:
                # 用'[ ]'切割line 並用.replace將':'替換為' ' 在用.split()去掉空格返回list型態資料
                # parts = ['Evaluations', '5678', 'Packets', '0', 'Bytes', '0', 'States', '0']
                parts = line.strip('[ ]').replace(':', ' ').split()
                # for i in range(0, 7, 2):
                # i = 0 > 2 > 4 > 6
                for i in range(0, len(parts)-1, 2):
                    # .isdigit()檢測字符串是否只由數字組成
                    # 若parts的[1]、[3]、[5]、[7]位是數字時
                    if parts[i+1].isdigit():
                        # lower() 轉換字符串中所有大寫字符為小寫
                        # 將parts的[0]、[2]、[4]、[6]中的字轉小寫，並設為key
                        # 將parts的[1]、[3]、[5]、[7]轉為int，並設為value
                        # {'evaluations': 5678, 'packets': 0, 'bytes': 0, 'states': 0}
                        stats[parts[i].lower()] = int(parts[i+1]) # 這裡第一次觸發時stats = {'pf_rules': 1} ，並將parts資料寫入stats
                        # 當results[rule_md5]有資料時，這裡才會將資料寫入results[rule_md5] = stats
                        # 結果: {"02f4bab031b57d1e30553ce08e0ec131":{'pf_rules': 1, 'evaluations': 5063, 'packets': 35, 'bytes': 3674, 'states': 0}}
                        print ('------stats------')
                        print (stats)
        output = ujson.dumps(results) # 將dict類型的數據轉換成str
        fhandle.seek(0) # 指標移到開頭
        fhandle.truncate() # 清除文件內容
        fhandle.write(output) # 將output寫入文件
        fhandle.close() # 關閉檔案
        print(output) # 回傳output
        print ('new')
    else:
        # output 
        print ('old')
        print (ujson.dumps(results)) # 將dict類型的數據轉換成str
