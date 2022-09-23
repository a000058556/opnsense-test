<?php
namespace OPNsense\HelloWorld\Api;
use \OPNsense\Core\Backend;

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
}