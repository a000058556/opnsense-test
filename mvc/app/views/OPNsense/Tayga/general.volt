{#

OPNsense® is Copyright © 2014 – 2020 by Deciso B.V.
This file is Copyright © 2020 by Michael Muenz <m.muenz@gmail.com>
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
                                <div class="content-box" style="padding-bottom: 1.5em;">
                                    {{ partial("layout_partials/base_form",['fields':generalForm,'id':'frm_general_settings'])}}
                                    <div class="col-md-12">
                                        <hr />
                                        <button class="btn btn-primary" id="saveAct" type="button"><b>{{ lang._('Save') }}</b> <i id="saveAct_progress"></i></button>
                                    </div>
                                </div>
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
        var data_get_map = {'frm_general_settings':"/api/tayga/general/get"};
        mapDataToFormUI(data_get_map).done(function(data){
            formatTokenizersUI();
            $('.selectpicker').selectpicker('refresh');
        });
        ajaxCall(url="/api/tayga/service/status", sendData={}, callback=function(data,status) {
            updateServiceStatusUI(data['status']);
        });

        // link save button to API set action
        $("#saveAct").click(function(){
            saveFormToEndpoint(url="/api/tayga/general/set", formid='frm_general_settings',callback_ok=function(){
                    $("#saveAct_progress").addClass("fa fa-spinner fa-pulse");
                    ajaxCall(url="/api/tayga/service/reconfigure", sendData={}, callback=function(data,status) {
                            ajaxCall(url="/api/tayga/service/status", sendData={}, callback=function(data,status) {
                                    updateServiceStatusUI(data['status']);
                            });
                            $("#saveAct_progress").removeClass("fa fa-spinner fa-pulse");
                    });
            });
        });
    });
</script>
