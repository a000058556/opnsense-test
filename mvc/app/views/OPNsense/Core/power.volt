{#
 # Copyright (c) 2019 Deciso B.V.
 # All rights reserved.
 #
 # Redistribution and use in source and binary forms, with or without modification,
 # are permitted provided that the following conditions are met:
 #
 # 1.  Redistributions of source code must retain the above copyright notice,
 # this list of conditions and the following disclaimer.
 #
 # 2.  Redistributions in binary form must reproduce the above copyright notice,
 # this list of conditions and the following disclaimer in the documentation
 # and/or other materials provided with the distribution.
 #
 # THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 # INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 # AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 # AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 # OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 # SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 # INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 # CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 # ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 # POSSIBILITY OF SUCH DAMAGE.
 #}
<div class="">
    <div class="row">
        <div class="col-md-6 widgetdiv">
            <div class="content-box" >
                <section class="widgetdiv" style="display:block;">
                    <table class="table table-striped" style="text-align:center;">
                        <tbody>
                            <tr>
                                <td>
                                    <div class="power-text" style="text-align: center;">
                                        <div style="display: revert;">
                                            Reboot
                                            <span class="fa fa-repeat fa-fw power-icon"></span>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <p style="margin: 15px auto;"><strong>{{ lang._('Are you sure you want to reboot the system?') }}</strong></p>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <button id="do-reboot" class="btn btn-primary">{{ lang._('reboot') }}</button>
                                    <!-- <a href="/" class="btn btn-default">{{ lang._('No') }}</a> -->
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </section>
            </div>
        </div>
        <div class="col-md-6 widgetdiv">
            <div class="content-box" >
                <section class="widgetdiv" style="display:block;">
                    <table class="table table-striped" style="text-align:center;">
                        <tbody>
                            <tr>
                                <td>
                                    <div class="power-text" style="text-align: center;">
                                        <div style="display: revert;">
                                            Power Off
                                            <span class="fa fa-power-off fa-fw power-icon"></span>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <p style="margin: 15px auto;"><strong>{{ lang._('Are you sure you want to power off the system?') }}</strong></p>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <button id="do-halt" class="btn btn-primary">{{ lang._('power off') }}</button>
                                    <!-- <a href="/" class="btn btn-default">{{ lang._('No') }}</a> -->
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </section>
            </div>
        </div>
    </div>
</div>


<!-- Power: Reboot -->
<script>
    'use strict';

    function rebootWait() {
        $.ajax({
            url: '/',
            timeout: 2500
        }).fail(function () {
            setTimeout(rebootWait, 2500);
        }).done(function () {
            $(location).attr('href', '/');
        });
    }

    $(document).ready(function() {
        $('#do-reboot').on('click', function() {
            BootstrapDialog.show({
                type:BootstrapDialog.TYPE_INFO,
                title: '{{ lang._('Your device is rebooting') }}',
                closable: false,
                onshow: function(dialogRef){
                    dialogRef.getModalBody().html(
                        '{{ lang._('The system is rebooting now, please wait...') }}' +
                        ' <i class="fa fa-cog fa-spin"></i>'
                );
                    ajaxCall('/api/core/system/reboot');
                    setTimeout(rebootWait, 45000);
                },
            });
        });
    });
</script>

<!-- Power: Power Off -->
<script>
    'use strict';

    $(document).ready(function() {
        $('#do-halt').on('click', function() {
            BootstrapDialog.show({
                type:BootstrapDialog.TYPE_INFO,
                title: '{{ lang._('Your device is powering off') }}',
                closable: false,
                onshow: function(dialogRef){
                    dialogRef.getModalBody().html('{{ lang._('The system is powering off now.') }}');
                    ajaxCall('/api/core/system/halt');
                },
            });
        });
    });
</script>