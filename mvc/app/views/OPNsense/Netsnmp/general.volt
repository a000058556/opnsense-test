{#

OPNsense® is Copyright © 2014 – 2018 by Deciso B.V.
This file is Copyright © 2018 by Michael Muenz <m.muenz@gmail.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

#}

<!-- Title -->
<div class="row heading-bg">
    <div class="col-lg-3 col-md-4 col-sm-4 col-xs-12">
        <h5 class="txt-dark">&nbsp;</h5>
    </div>

    <!-- Breadcrumb -->
    <div class="col-lg-9 col-sm-8 col-md-8 col-xs-12">
        <ol class="breadcrumb">
            <li><a href="index.html">#1</a></li>
            <li><a href="#"><span>#2</span></a></li>
            <li class="active"><span>#3</span></li>
        </ol>
    </div>
    <!-- /Breadcrumb -->

</div>
<!-- /Title -->

<!-- Row -->
<div class="row">
    <div class="col-md-12">
        <div class="panel panel-default card-view">
            <div class="panel-heading">
                <div class="pull-left">
                    <h6 class="panel-title txt-dark">{{title | default("")}}</h6>
                </div>
                <div class="clearfix"></div>
            </div>
            <div class="panel-wrapper collapse in">
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-wrap">
                                
                                <!-- content *START* -->

                                <!-- Navigation bar -->
                                <ul class="nav nav-tabs" data-tabs="tabs" id="maintabs">
                                    <li class="active"><a data-toggle="tab" href="#general">{{ lang._('General') }}</a></li>
                                    <li><a data-toggle="tab" href="#users">{{ lang._('SNMPv3 Users') }}</a></li>
                                </ul>

                                <div class="tab-content content-box tab-content">
                                    <div id="general" class="tab-pane fade in active">
                                        <div class="content-box" style="padding-bottom: 1.5em;">
                                            {{ partial("layout_partials/base_form",['fields':generalForm,'id':'frm_general_settings'])}}
                                            <div class="col-md-12">
                                                <hr />
                                                <button class="btn btn-primary"  id="saveAct" type="button"><b>{{ lang._('Save') }}</b><i id="saveAct_progress"></i></button>
                                            </div>
                                        </div>
                                    </div>
                                    <div id="users" class="tab-pane fade in">
                                        <table id="grid-users" class="table table-responsive" data-editDialog="dialogEditNetsnmpUser">
                                            <thead>
                                                <tr>
                                                    <th data-column-id="enabled" data-type="string" data-formatter="rowtoggle">{{ lang._('Enabled') }}</th>
                                                    <th data-column-id="username" data-type="string" data-visible="true">{{ lang._('Username') }}</th>
                                                    <th data-column-id="password" data-type="string" data-visible="true">{{ lang._('Password') }}</th>
                                                    <th data-column-id="enckey" data-type="string" data-visible="true">{{ lang._('Encryption Key') }}</th>
                                                    <th data-column-id="uuid" data-type="string" data-identifier="true" data-visible="false">{{ lang._('ID') }}</th>
                                                    <th data-column-id="commands" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                            <tfoot>
                                                <tr>
                                                    <td colspan="5"></td>
                                                    <td>
                                                        <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                                                    </td>
                                                </tr>
                                            </tfoot>
                                        </table>
                                        <div class="col-md-12">
                                            <hr />
                                            <button class="btn btn-primary"  id="saveAct_user" type="button"><b>{{ lang._('Save') }}</b><i id="saveAct_user_progress"></i></button>
                                            <br /><br />
                                        </div>
                                    </div>
                                </div>

                                {{ partial("layout_partials/base_dialog",['fields':formDialogEditNetsnmpUser,'id':'dialogEditNetsnmpUser','label':lang._('Edit User')])}}


                                <!-- content *END* -->

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- /Row -->

<script>
$( document ).ready(function() {
    var data_get_map = {'frm_general_settings':"/api/netsnmp/general/get"};
    mapDataToFormUI(data_get_map).done(function(data){
        formatTokenizersUI();
        $('.selectpicker').selectpicker('refresh');
    });

    ajaxCall(url="/api/netsnmp/service/status", sendData={}, callback=function(data,status) {
        updateServiceStatusUI(data['status']);
    });

    $("#grid-users").UIBootgrid(
        {   'search':'/api/netsnmp/user/searchUser',
            'get':'/api/netsnmp/user/getUser/',
            'set':'/api/netsnmp/user/setUser/',
            'add':'/api/netsnmp/user/addUser/',
            'del':'/api/netsnmp/user/delUser/',
            'toggle':'/api/netsnmp/user/toggleUser/'
        }
    );

    $("#saveAct").click(function(){
        saveFormToEndpoint(url="/api/netsnmp/general/set", formid='frm_general_settings',callback_ok=function(){
        $("#saveAct_progress").addClass("fa fa-spinner fa-pulse");
            ajaxCall(url="/api/netsnmp/service/reconfigure", sendData={}, callback=function(data,status) {
                ajaxCall(url="/api/netsnmp/service/status", sendData={}, callback=function(data,status) {
                    updateServiceStatusUI(data['status']);
                });
                $("#saveAct_progress").removeClass("fa fa-spinner fa-pulse");
            });
        });
    });

    $("#saveAct_user").click(function(){
        saveFormToEndpoint(url="/api/netsnmp/user/set", formid='frm_general_settings',callback_ok=function(){
        $("#saveAct_user_progress").addClass("fa fa-spinner fa-pulse");
            ajaxCall(url="/api/netsnmp/service/reconfigure", sendData={}, callback=function(data,status) {
                ajaxCall(url="/api/netsnmp/service/status", sendData={}, callback=function(data,status) {
                    updateServiceStatusUI(data['status']);
                });
                $("#saveAct_user_progress").removeClass("fa fa-spinner fa-pulse");
            });
        });
    });

});
</script>
