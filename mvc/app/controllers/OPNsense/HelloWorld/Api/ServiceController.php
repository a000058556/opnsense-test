<?php
namespace OPNsense\HelloWorld\Api;
use \OPNsense\Core\Backend; // 使用後端通信

use \OPNsense\Base\ApiControllerBase;
class ServiceController extends ApiControllerBase 
{
    public function reloadAction()
    {
        $status = "failed";
        if ($this->request->isPost()) {
            $backend = new Backend();
            $bckresult = trim($backend->configdRun("template reload OPNsense/HelloWorld"));
            if ($bckresult == "OK") {
                $status = "ok";
            }
        }
        return array("status" => $status);
    }

    public function testAction()
    {
        if ($this->request->isPost()) {
            $backend = new Backend();
            $bckresult = json_decode(trim($backend->configdRun("helloworld test")), true);
            if ($bckresult !== null) {
                // only return valid json type responses
                return $bckresult;
            }
        }
        return array("message" => "unable to run config action");
    }
}


