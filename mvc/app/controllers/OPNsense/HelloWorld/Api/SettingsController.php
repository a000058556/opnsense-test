<?php
namespace OPNsense\HelloWorld\Api;

use \OPNsense\Base\ApiControllerBase;
use \OPNsense\HelloWorld\HelloWorld;


class SettingsController extends ApiControllerBase
{
    public function getAction()
    {
        // define list of configurable settings
        $result = array();
        if ($this->request->isGet()) {
            $mdlHelloWorld = new HelloWorld();
            $result['helloworld'] = $mdlHelloWorld->getNodes();
        }
        return $result;
    }
}