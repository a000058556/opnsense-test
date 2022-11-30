<script>
    $( document ).ready(function() {
        $("#grid-vips").UIBootgrid({
          search:'/api/diagnostics/interface/get_vip_status/',
          options:{
              requestHandler: function(request){
                  if ( $('#mode_filter').val().length > 0) {
                      request['mode'] = $('#mode_filter').val();
                  }
                  return request;
              },
              responseHandler: function (data) {
                  if (typeof data.carp === 'object') {
                      $("#carp_demotion_level").text(data.carp.demotion);
                      $(".carp_action").hide();
                      if (data.carp.allow == '0') {
                          $("#carp_allowed").html('<span class="fa fa-fw fa-times"></span>');
                          $("#carp_status_enable").show();
                      } else {
                          $("#carp_allowed").html('<span class="fa fa-fw fa-check"></span>');
                          $("#carp_status_disable").show();
                      }
                      if (data.carp.maintenancemode == '1') {
                          $("#carp_maintance_mode").html('<span class="fa fa-fw fa-check"></span>');
                          $("#carp_status_maintenance > b").text("{{ lang._('Leave Persistent CARP Maintenance Mode') }}");
                      } else {
                          $("#carp_maintance_mode").html('');
                          $("#carp_status_maintenance > b").text("{{ lang._('Enter Persistent CARP Maintenance Mode') }}");
                      }
                      $("#carp_status_maintenance").show();
                      if (data.carp.status_msg !== '') {
                          $("#carp_status_msg").html($("<div>").html(data.carp.status_msg).text()).show();
                      } else {
                          $("#carp_status_msg").hide();
                      }
                  }
                  return data;
              },
              formatters: {
                  vhid: function (column, row) {
                      return row.vhid_txt;
                  },
                  status: function (column, row) {
                      let icon = 'fa fa-info-circle fa-fw';
                      if (row.status == 'MASTER') {
                          icon = 'fa fa-play fa-fw text-success';
                      } else if (row.status == 'BACKUP') {
                          icon = 'fa fa-play fa-fw text-muted';
                      } else if (row.status == 'DISABLED') {
                          icon = 'fa fa-remove fa-fw text-danger';
                      }
                      return '<span class="'+icon+'"></span> &nbsp;' + row.status_txt;
                  },
              }
          }
        });
        $("#grid-pfsyncnodes").UIBootgrid({
          search:'/api/diagnostics/interface/get_pfsync_nodes/',
        });
        $("#mode_filter").change(function(){
            $('#grid-vips').bootgrid('reload');
        });

        $("#mode_filter_container").detach().prependTo('#grid-vips-header > .row > .actionBar > .actions');

        $(".carp_action").each(function(){
          $(this).SimpleActionButton({onAction: function(data, status){
            $('#grid-vips').bootgrid('reload');
          }});
        });
    });
</script>

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

                                <ul class="nav nav-tabs" data-tabs="tabs" id="maintabs">
                                    <li class="active"><a data-toggle="tab" href="#addresses">{{ lang._('Addresses') }}</a></li>
                                    <li><a data-toggle="tab" href="#pfsync">{{ lang._('pfSync nodes') }}</a></li>
                                </ul>
                                <div class="tab-content content-box">
                                    <div id="addresses" class="tab-pane fade in active">
                                      <div class="hidden">
                                          <!-- filter per type container -->
                                          <div id="mode_filter_container" class="btn-group">
                                              <select id="mode_filter"  data-title="{{ lang._('Filter type') }}" class="selectpicker" multiple="multiple" data-width="200px">
                                                  <option value="ipalias">{{ lang._('IP Alias') }}</option>
                                                  <option value="carp" selected="selected">{{ lang._('CARP') }}</option>
                                              </select>
                                          </div>
                                      </div>
                                      <div id="carp_status_msg" class="alert alert-warning" style="display: none; margin: 10px;" role="alert">
                                      </div>
                                      <table id="grid-vips" class="table table-condensed table-hover table-striped">
                                          <thead>
                                              <tr>
                                                  <th data-column-id="interface" data-type="string">{{ lang._('Interface') }}</th>
                                                  <th data-column-id="vhid" data-type="string" data-formatter="vhid" >{{ lang._('VHID') }}</th>
                                                  <th data-column-id="subnet" data-type="string" data-identifier="true">{{ lang._('Address') }}</th>
                                                  <th data-column-id="status" data-type="string" data-formatter="status">{{ lang._('Status') }}</th>
                                              </tr>
                                          </thead>
                                          <tbody>
                                          </tbody>
                                      </table>
                                      <table class="table table-condensed" >
                                        <tbody>
                                          <tr>
                                              <td style="width:200px;">{{ lang._('Carp allowed')}}</td>
                                              <td id='carp_allowed' style="width:50px;">-</td>
                                              <td>
                                                  <button class="btn btn-primary carp_action" id="carp_status_enable" style="display: none;"
                                                          data-endpoint='/api/diagnostics/interface/carp_status/enable'
                                                          data-label="{{ lang._('Enable CARP') }}"
                                                          data-error-title="{{ lang._('Error changing status') }}"
                                                          type="button"
                                                  ></button>
                                                  <button class="btn btn-primary carp_action" id="carp_status_disable" style="display: none;"
                                                          data-endpoint='/api/diagnostics/interface/carp_status/disable'
                                                          data-label="{{ lang._('Temporarily Disable CARP') }}"
                                                          data-error-title="{{ lang._('Error changing status') }}"
                                                          type="button"
                                                  ></button>
                                              </td>
                                          </tr>
                                          <tr>
                                              <td>{{ lang._('Persistent maintance mode')}}</td>
                                              <td id='carp_maintance_mode'>-</td>
                                              <td>
                                                <button class="btn btn-primary carp_action" id="carp_status_maintenance" style="display: none;"
                                                        data-endpoint='/api/diagnostics/interface/carp_status/maintenance'
                                                        data-label="{{ lang._('Toggle') }}"
                                                        data-error-title="{{ lang._('Error changing status') }}"
                                                        type="button"
                                                ></button>
                                              </td>
                                          </tr>
                                          <tr>
                                              <td>{{ lang._('Current CARP demotion level')}}</td>
                                              <td id='carp_demotion_level'>-</td>
                                          </tr>
                                        </tbody>
                                      </table>
                                    </div>
                                    <div id="pfsync" class="tab-pane fade in">
                                      <table id="grid-pfsyncnodes" class="table table-condensed table-hover table-striped">
                                          <thead>
                                              <tr>
                                                  <th data-column-id="creatorid" data-type="string">{{ lang._('Hostid') }}</th>
                                                  <th data-column-id="this" data-type="boolean" data-formatter="boolean" >{{ lang._('This node') }}</th>
                                              </tr>
                                          </thead>
                                          <tbody>
                                          </tbody>
                                      </table>
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
