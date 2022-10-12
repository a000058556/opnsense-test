

<script>
    $( document ).ready(function() {
        /**
         * fetch system arp table
         */
        function updateARP() {
            if ($("#grid-arp").hasClass('bootgrid-table')) {
                $("#grid-arp").bootgrid('clear');
            } else {
                $("#grid-arp").bootgrid({
                    ajax: false,
                    selection: false,
                    multiSelect: false
                });
            }
            ajaxGet("/api/diagnostics/interface/getArp", {}, function (data, status) {
                        if (status == "success") {
                            $("#grid-arp").bootgrid('append', data);
                        }
                    }
            );
        }

        $("#flushModal").click(function(event){
          BootstrapDialog.show({
            type:BootstrapDialog.TYPE_DANGER,
            title: "<?= $lang->_('Flush ARP Table') ?>",
            message: "<?= $lang->_('Flush the ARP cache manually, in case your ARP cache contains invalid data.') ?>",
            buttons: [{
                      label: "<?= gettext('Close');?>",
                      action: function(dialogRef) {
                        dialogRef.close();
                      }}, {
                      label: "<?= gettext('Flush ARP Table');?>",
                      action: function(dialogRef) {
                        ajaxCall("/api/diagnostics/interface/flushArp", {}, function (data, status) {
                            $("#refresh").click();
                        });
                    }
                  }]
          }); // end BootstrapDialog.show
        }); // end .click(function(event)

        // initial fetch
        $("#refresh").click(updateARP);
        $("#refresh").click();
    });
</script>

<div class="content-box">
    <div class="content-box-main">
        <div class="table-responsive">
            <div  class="col-sm-12">
                <table id="grid-arp" class="table table-condensed table-hover table-striped table-responsive">
                    <thead>
                    <tr>
                        <th data-column-id="ip" data-type="string"  data-identifier="true"><?= $lang->_('IP') ?></th>
                        <th data-column-id="mac" data-type="string" data-identifier="true"><?= $lang->_('MAC') ?></th>
                        <th data-column-id="manufacturer" data-type="string" data-css-class="hidden-xs hidden-sm" data-header-css-class="hidden-xs hidden-sm"><?= $lang->_('Manufacturer') ?></th>
                        <th data-column-id="intf" data-type="string" data-css-class="hidden-xs hidden-sm" data-header-css-class="hidden-xs hidden-sm"><?= $lang->_('Interface') ?></th>
                        <th data-column-id="intf_description" data-type="string" data-css-class="hidden-xs hidden-sm" data-header-css-class="hidden-xs hidden-sm"><?= $lang->_('Interface name') ?></th>
                        <th data-column-id="hostname" data-type="string" data-css-class="hidden-xs hidden-sm" data-header-css-class="hidden-xs hidden-sm"><?= $lang->_('Hostname') ?></th>
                    </tr>
                    </thead>
                    <tbody>
                    </tbody>
                    <tfoot>
                    <tr>
                        <td colspan="6"><?= $lang->_('NOTE: Local IPv6 peers use NDP instead of ARP.') ?></td>
                    </tr>
                    </tfoot>
                </table>
            </div>
            <div  class="col-sm-12">
                <div class="row">
                    <div class="col-xs-12">
                        <div class="pull-right">
                            <button type="button" class="btn btn-default" id="flushModal">
                                <span><?= $lang->_('Flush') ?></span>
                                <span class="fa fa-trash"></span>
                            </button>
                            <button id="refresh" type="button" class="btn btn-default">
                                <span><?= $lang->_('Refresh') ?></span>
                                <span class="fa fa-refresh"></span>
                            </button>
                        </div>
                    </div>
                </div>
                <hr/>
            </div>
        </div>
    </div>
</div>
