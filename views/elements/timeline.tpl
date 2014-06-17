{$coeff=$html->params.named.coeff|default:$html->params.url.coeff|default:20}

<div class="timeline" data-timeline-start="{$prevmonday|date_format:'%D'}">

    <header style="padding-bottom:20px;">
        <table style="width:100%;">
            <tr>
                <td style="border-left:1px solid rgba(255,255,255,.3)">{$prevmonday|date_format:'%a %d %b'}</td>
            </tr>
        </table>
        <div class="today">today</div>
    </header>

    <div class="matrix" style="width:100%">

    <!-- TODO foreach pubblicazioni -->

        <div class="tab"><h2>Il cricco di teodoro</h2></div>

        <div id="niknamepubblicazione">  
        {foreach from=$tickets item=ticket}
            {if !empty($ticket.subtasks)}
                <div class="mainticket"> <!-- ticket principale -->
                    <div class="thead"><span class="plusminus"></span>{$ticket.title} <a href="{$html->url('/')}view/{$ticket.id}">view</a></div>
                    {foreach from=$ticket.subtasks|default:[] item=subtask}
                        {if !empty($subtask.start_date) && !empty($subtask.exp_resolution_date)}
                            {$assigned = array()}
                            <div class="flowticket {$subtask.Category.0.name|default:''} {$subtask.status} {$subtask.ticket_status}" 
                            style="margin-left:{$subtask.shift*$coeff}px; width:{$subtask.days*$coeff}px !important; 
                            {if !empty($subtask.delay)}
                                border-right:{$subtask.delay*$coeff}px solid rgba(255,0,0,1)
                            {/if}"
                            data-start="{$subtask.start_date|date_format:'%a %d %b %Y'}"
                            data-end="{$subtask.exp_resolution_date|date_format:'%a %d %b %Y'}"
                            >
                                {$subtask.Category.0.name|default:''} {$subtask.ticket_status|default:''} {$subtask.title|default:''}
                                {if ($subtask.Annotation|@count > 0)}<span class="ncomments">{$subtask.Annotation|@count}</span>{/if}
                                {$view->element('timeline_info_ticket',['subtask' => $subtask])}
                            </div>
                        {/if}
                    {/foreach} 
                </div>
            {/if}
        {/foreach}  	
        </div> <!-- closing pubb -->
        <div class="highlight-day"></div>
    </div> <!-- closing matrix -->
</div> <!-- closing timeline -->

<style scoped>

    .timeline header {
        background-image: linear-gradient(90deg, rgba(255,255,255,.3) 1px, transparent 1px);
        background-size:{$coeff*7}px {$coeff*5}px, {$coeff*7}px {$coeff*7}px, {$coeff}px {$coeff}px, {$coeff}px {$coeff}px;
    }

    .matrix {
        position: relative;
        background-color:rgba(255,255,255,0);
        background-image: linear-gradient(white 0px, transparent 0px),
        linear-gradient(90deg, rgba(128,128,128,.2) {$coeff*2}px, transparent 1px),
        linear-gradient(rgba(255,255,255,.3) 0px, transparent 0px),
        linear-gradient(90deg, rgba(255,255,255,.3) 1px, transparent 1px);
        background-size:{$coeff*7}px {$coeff*5}px, {$coeff*7}px {$coeff*7}px, {$coeff}px {$coeff}px, {$coeff}px {$coeff}px;
        background-position: -{$coeff*2}px;
    }

    .highlight-day {
        width: {$coeff}px;
        height: 100%;
        top: 0;
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
        border-radius: 4px;
        z-index: 3;
    }

    .today {
        width: {$coeff}px;
        color:red;
        position:absolute;
        margin-top:-27px;
        padding-top:20px;
        height:100%;
        padding-left:5px;
        border-left: 1px solid rgba(255,0,0,1);
        margin-left: {$todayshift*$coeff}px;
        background: transparent;
        z-index: 3;
        pointer-events: none;
     }

</style>

<script>
    $(function(){
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
                .attr('data-date', d.getFullYear()+'-'+month+'-'+day)
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
            startEl.datepicker('setDate', new Date(startDate) );
            endEl.datepicker('setDate', new Date(endDate) );
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
            if ($(ev.target).is('.info_ticket, .info_ticket *')) {
                return true;
            } else {
                $(".info_ticket").fadeOut( 100 );
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
                $(".info_ticket").not(info).fadeOut( 100 );
                if (!info.is(':visible')) {
                    info.css({
                        left: ev.pageX - $(that).offset().left - 15
                    })
                }
                info.fadeToggle( 150 );
            }
            return false;
        }).each(function() {
            updateDates(this);
        }).not('.off').draggable({
            axis: "x",
            cursor: "move",
            grid: [ {$coeff}, {$coeff} ],
            start: function() {
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

        $(".thead").click(function(){
            $(this).closest(".mainticket").toggleClass("closed");
        });

    });
</script>


{*dump var=$tickets|default:''*}