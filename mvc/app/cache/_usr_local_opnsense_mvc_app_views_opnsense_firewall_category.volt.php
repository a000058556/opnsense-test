

<?php $theme_name = (empty($ui_theme) ? ('opnsense') : ($ui_theme)); ?>
<link rel="stylesheet" type="text/css" href="<?= view_cache_safe(view_fetch_themed_filename('/css/pick-a-color-1.2.3.min.css', $theme_name)) ?>">
<script src="<?= view_cache_safe('/ui/js/pick-a-color-1.2.3.min.js') ?>"></script>
<script src="<?= view_cache_safe('/ui/js/tinycolor-1.4.1.min.js') ?>"></script>

<script>

    $( document ).ready(function() {
        /*************************************************************************************************************
         * link grid actions
         *************************************************************************************************************/
        $("#grid-categories").UIBootgrid(
                {   search:'/api/firewall/category/searchItem',
                    get:'/api/firewall/category/getItem/',
                    set:'/api/firewall/category/setItem/',
                    add:'/api/firewall/category/addItem/',
                    del:'/api/firewall/category/delItem/',
                    options:{
                        formatters:{
                            color: function (column, row) {
                                if (row.color != "") {
                                    return "<i style='color:#"+row.color+";' class='fa fa-circle'></i>";
                                }
                            },
                            commands: function (column, row) {
                                return "<button type=\"button\" class=\"btn btn-xs btn-default command-edit bootgrid-tooltip\" data-row-id=\"" + row.uuid + "\"><span class=\"fa fa-pencil fa-fw\"></span></button> " +
                                    "<button type=\"button\" class=\"btn btn-xs btn-default command-copy bootgrid-tooltip\" data-row-id=\"" + row.uuid + "\"><span class=\"fa fa-clone fa-fw\"></span></button>" +
                                    "<button type=\"button\" class=\"btn btn-xs btn-default command-delete bootgrid-tooltip\" data-row-id=\"" + row.uuid + "\"><span class=\"fa fa-trash-o fa-fw\"></span></button>";
                            },
                            boolean: function (column, row) {
                                if (parseInt(row[column.id], 2) === 1) {
                                    return "<span class=\"fa fa-check\" data-value=\"1\" data-row-id=\"" + row.uuid + "\"></span>";
                                } else {
                                    return "<span class=\"fa fa-times\" data-value=\"0\" data-row-id=\"" + row.uuid + "\"></span>";
                                }
                            },
                        }
                    }

                }
        );
        $(".pick-a-color").pickAColor({
            showSpectrum: true,
            showSavedColors: true,
            saveColorsPerElement: true,
            fadeMenuToggle: true,
            showAdvanced : false,
            showBasicColors: true,
            showHexInput: true,
            allowBlank: true,
            inlineDropdown: true
        });
        $("#category\\.color").change(function(){
            // update color picker
            $(this).blur().blur();
        });

    });

</script>

<!-- 表格選單 -->
<ul class="nav nav-tabs" data-tabs="tabs" id="maintabs">
    <li class="active"><a data-toggle="tab" href="#grid-categories"><?= $lang->_('Categories') ?></a></li>
</ul>
<!-- 主要表格 -->
<div class="tab-content content-box">
    <div id="categories" class="tab-pane fade in active">
        <table id="grid-categories" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="DialogEdit">
            <thead>
            <tr>
                <th data-column-id="color" data-width="2em" data-type="string" data-formatter="color"></th>
                <th data-column-id="name" data-type="string"><?= $lang->_('Name') ?></th>
                <th data-column-id="auto" data-width="6em" data-type="string" data-formatter="boolean"><?= $lang->_('Auto') ?></th>
                <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false"><?= $lang->_('Commands') ?></th>
                <th data-column-id="uuid" data-type="string" data-identifier="true" data-visible="false"><?= $lang->_('ID') ?></th>
            </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-primary"><span class="fa fa-plus fa-fw"></span></button>
                    <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o fa-fw"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
</div>


<?= $this->partial('layout_partials/base_dialog', ['fields' => $formDialogEdit, 'id' => 'DialogEdit', 'label' => $lang->_('Edit category')]) ?>
