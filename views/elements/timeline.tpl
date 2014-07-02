{$coeff=$html->params.named.coeff|default:$html->params.url.coeff|default:20}
<div class="timeline" data-timeline-start="{$prevmonday|date_format:'%D'}">
    <header style="padding-bottom:20px;">
        <table style="width:100%;">
            <tr>
                <td style="border-left:1px solid rgba(255,255,255,.3)">{$prevmonday|date_format:'%a %d %b'}</td>
            </tr>
        </table>
        <div class="t_today">today</div>
    </header>
    <div class="matrix">
    <!-- TODO foreach pubblicazioni -->
    {foreach from=$pubtickets item=pubticket key=key}
    {if !empty($pubticket)}
        <div class="tab"><h2>{$key|upper} &nbsp;&nbsp;&nbsp;<span class="relnumb">{$pubticket|@count} tickets</span></h2></div>
        <div id="{$key}"> 
            {foreach from=$pubticket item=ticket}
                <div class="mainticket"> <!-- ticket principale -->

                    <table class="thead" style="
                    {if !empty($ticket.general_days)}
                        width:{$ticket.general_days*$coeff}px;
                    {/if}
                    {if !empty($ticket.general_days) && ($ticket.general_days < 0)}
                        display:none
                    {/if}
                    ">
                        <tr>
                            
                            <td class="ticket_title" style="width:100%; border-right:1px solid #dedede">
                                <span class="plusminus"></span>&nbsp;&nbsp;

                                {$ticket.title} 
                                <!--
                                &nbsp;&nbsp;&nbsp;<span class="relnumb">{$ticket.subtasks|@count|default:0} subtask</span>
                                &nbsp;&nbsp;&nbsp;{$ticket.general_end|date_format:"%x"|default:''} 
                                &nbsp;&nbsp;&nbsp;{$ticket.general_days|default:''} -->
                            </td>
                            <td style="text-align:right; padding-right:10px; border-right:1px solid #dedede">
                                {$ticket.subtasks|@count|default:0} subtask
                            </td>
                            <td style="text-align:right; padding-right:10px; border-right:1px solid #dedede">
                                <a class="addsubtask" href="#">add</a>
                                 {$view->element('timeline_info_ticket',['parent' => $ticket])}
                            </td>
                            <td style="text-align:right; padding-right:10px">
                                <a target="_blank" href="{$html->url('/')}view/{$ticket.id}">view</a>
                            </td>
                        </tr>
                    </table>

                    {if !empty($ticket.subtasks)}
                        {foreach from=$ticket.subtasks|default:[] item=subtask}
                            {if !empty($subtask.start_date) && !empty($subtask.exp_resolution_date)}
                                {$assigned = array()}
                                <div class="flowticket {$subtask.Category.0.name|default:''} {$subtask.status} {$subtask.ticket_status}" 
                                style="margin-left:{$subtask.shift*$coeff}px; width:{$subtask.days*$coeff}px !important; 
                                {if !empty($subtask.delay)}
                                    border-right:{($subtask.delay)*$coeff}px solid rgba(255,0,0,1)
                                {/if}"
                                data-start="{$subtask.start_date}"
                                data-end="{$subtask.exp_resolution_date}">
                                    {$subtask.Category.0.name|default:''} 
                                    &nbsp;&nbsp; / {$subtask.ticket_status|default:''} 
                                     <!-- {$subtask.title|default:''} -->
                                    <!-- {if ($subtask.Annotation|@count > 0)}<span class="ncomments">{$subtask.Annotation|@count} comments</span>{/if} -->
                                    {$view->element('timeline_info_ticket',['subtask' => $subtask])}
                                </div>
                            {/if}
                        {/foreach} 
                    {/if}
                </div>
            {/foreach}
        </div> <!-- closing pubb -->
    {/if}
    {/foreach} 
        <div class="highlight-day"></div>
    </div> <!-- closing matrix -->
</div> <!-- closing timeline -->

<style scoped>
    .timeline header {
        background-size:{$coeff*7}px {$coeff*5}px, {$coeff*7}px {$coeff*7}px, {$coeff}px {$coeff}px, {$coeff}px {$coeff}px;
    }
    .matrix {
        background-image:   linear-gradient(white 0px, transparent 0px),
                            linear-gradient(90deg, rgba(128,128,128,.2) {$coeff*2}px, transparent 1px),
                            linear-gradient(rgba(255,255,255,.3) 0px, transparent 0px),
                            linear-gradient(90deg, rgba(255,255,255,.3) 1px, transparent 1px);
        background-size:{$coeff*7}px {$coeff*5}px, {$coeff*7}px {$coeff*7}px, {$coeff}px {$coeff}px, {$coeff}px {$coeff}px;
        background-position: -{$coeff*2}px;
    }
    .t_today {
        {if $todayshift < 0}
            display:none;
        {else}
            margin-left:{$todayshift*$coeff+1}px;
        {/if}
        border-left:{$coeff-1}px solid rgba(255,0,0,.2);
        /*width: {$coeff}px;*/
    }
    .highlight-day {
        width: {$coeff}px;
        height: 100%;
        top: -75px;
        position: absolute;
        display: none;
        background-color: rgba(255, 255, 0, 0.25);
        pointer-events: none;
        z-index: 1;
    }
    .highlight-day:before {
        content: attr(data-date);
        position: absolute;
        left: -1000px;
        right: -1000px;
        top: 26px;
        margin: auto;
        display: inline-block;
        text-align: center;
        padding: 1px 5px;
        background-color: #000;
        background-color: rgba(0, 0, 0, 0.75);
        color: #FFF;
        width: 90px;
        border-radius: 0px;
        z-index: 3;
    }
</style>

<script>
    $(function(){
        var ts = JSON.parse('{$conf->ticketStatus|json_encode}');
        var movingTicket = false;
        var dayToTime = 1000 * 60 * 60 * 24;

        var timelineStart = new Date($('.timeline').data('timeline-start')).valueOf();

        $('.timeline .matrix').bind('mousemove', function(ev) {
            if (ev.target.tagName == 'H2') {
                return true;
            }
            var left = ev.pageX - $(this).offset().left;
            var days = Math.floor(left / {$coeff});
            var d = new Date((days-1) * dayToTime + timelineStart);

            var month = d.getMonth()+1;
            if (month < 10) month = '0' + month;

            var day = d.getDate()+1;
            if (day < 10) day = '0' + day;

            $('.highlight-day', this)
                .show()
                //.attr('data-date', d.getFullYear()+'-'+month+'-'+day)
                .attr('data-date', day+'-'+month+'-'+d.getFullYear())
                .css('left', days * {$coeff});
        }).bind('mouseout', function(ev) {
            $('.highlight-day').hide();
        });

        var updateDates = function(t, ui) {
            var pos = ui ? ui.position.left : 0;
            var dif = dayToTime * pos / {$coeff};
            var startDate = new Date($(t).data('start')).valueOf();
            var endDate = startDate + dayToTime * $(t).width() / {$coeff};
            startDate += dif;
            endDate += dif;
            var startEl = $('[name="data[start_date]"]', t);
            var endEl = $('[name="data[exp_resolution_date]"]', t);
            startDate = new Date(startDate);
            endDate = new Date(endDate);
            startEl.datepicker('setDate', startDate);
            endEl.datepicker('setDate', endDate);
            var durate = (endDate.valueOf() - startDate.valueOf()) / (1000 * 60 * 60 * 24);
            $(t).find('.durate-field').text(durate);
        }

        $('.dateinput').datepicker({
            onSelect: function(ev, ui) {
                var t = $(this).closest('.flowticket');
                var startEl = t.find('[name="data[start_date]"]');
                var endEl = t.find('[name="data[exp_resolution_date]"]');

                var initDate = new Date(t.data('start')).valueOf();
                var endDate = endEl.datepicker('getDate').valueOf();
                var newStart = startEl.datepicker('getDate').valueOf();
                var newEnd = endDate;

                var d = new Date(ui.selectedYear + '/' + (ui.selectedMonth+1) + '/' + ui.selectedDay);
                if ($(this).is('[name="data[start_date]"]')) {
                    newStart = d.valueOf();
                } else {
                    newEnd = d.valueOf();
                }

                var left = {$coeff} * (newStart - initDate) / dayToTime;
                var width = {$coeff} * (newEnd - newStart) / dayToTime;
                t.css({
                    left: left,
                    width: width
                });
                
                var start = startEl.data('date');
            }
        });

        $(document).click(function(ev) {
            if ($(ev.target).is('.info_ticket, .info_ticket *,.addsubtask')) {
                return true;
            } else {
                $(".info_ticket").fadeOut( 100 ).closest('.flowticket').removeClass('active');
            }
        });

        $( ".flowticket" ).click(function(ev) {
            ev.stopPropagation();
            var that = this;
            if ($(ev.target).is('.info_ticket, .info_ticket *')) {
                return true;
            }
            if (!movingTicket) {
                var info = $(".info_ticket", that);
                $(".info_ticket").not(info).fadeOut( 100 ).closest('.flowticket').removeClass('active');
                if (!info.is(':visible')) {
                    info.css({
                        left: ev.pageX - $(that).offset().left - 15
                    })
                }
                $(that).toggleClass('active');
                info.fadeToggle( 150 );
            }
            return false;
        }).each(function() {
            updateDates(this);
        }).not('.off').draggable({
            axis: "x",
            cursor: "move",
            grid: [ {$coeff}, {$coeff} ],
            delay: 1000,
            start: function() {
                var info = $(".info_ticket", this);
                $(".info_ticket").not(info).fadeOut( 100 ).closest('.flowticket').removeClass('active');
                movingTicket = true;
            },
            drag: function(event, ui) {
                movingTicket = true;
                updateDates(this, ui);
            },
            stop: function() {
                setTimeout(function() {
                    movingTicket = false;
                }, 100)
            }
        }).resizable({
            handles: "e, w",
            start: function() {
                var info = $(".info_ticket", this);
                $(".info_ticket").not(info).fadeOut( 100 ).closest('.flowticket').removeClass('active');
                movingTicket = true;
            },
            grid: [ {$coeff}, {$coeff} ],
            resize: function(event, ui) {
                movingTicket = true;
                updateDates(this, ui);
            },
            stop: function() {
                setTimeout(function() {
                    movingTicket = false;
                }, 100)
            }
        });

        $(".ticket_title",".thead").click(function(){
            $(this).closest(".mainticket").toggleClass("closed");

        });

        $(".thead").each(function(){
             var _thead = $(this);
             $(".addsubtask",_thead).click(function(){
                   $(".info_ticket",_thead).toggle();
             });

        });

        // save
        $('.info_ticket').find('form').submit(function(e) {
            e.preventDefault();
            var that = this;
            // update status
            var ticketStatus = $(this).find('select[name*=ticket_status]').val();
            $(this).find('input[name=data\\[status\\]]').val(ts[ticketStatus]);

            $(this).ajaxSubmit({
                dataType: 'json',
                beforeSubmit: function() {
                    $(that).hide();
                    $(that).parents('.info_ticket:first').addClass('loader').show();
                },
                success: function(data) {
                    $(that).parents('.info_ticket:first').removeClass('loader');
                    $(that).show();
                    // data contains object data saved
                    if (typeof data != 'undefined' && data.id) {
                        // update timeline
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.error('textStatus: ' + textStatus + ', errorThrown: ' + errorThrown);
                    $(that).show()
                    $(that).parents('.info_ticket:first');
                    try {
                        if (jqXHR.responseText) {
                            var data = JSON.parse(jqXHR.responseText);
                            if (typeof data != 'undefined' && data.errorMsg && data.htmlMsg) {
                                $('#messagesDiv').empty();
                                $('#messagesDiv').html(data.htmlMsg).triggerMessage('error');
                            }
                        }
                    } catch (e) {
                        console.error("Missing responseText or it's not a valid json");
                    }
                }
            });
            return false;
        });


    });
</script>
{*dump var=$tickets|default:''*}