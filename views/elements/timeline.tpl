{$coeff=$html->params.named.coeff|default:$html->params.url.coeff|default:20}

{$html->script('/tickets/js/moment-with-langs.min')}
<div class="timeline">

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
           
            <div class="thead"><span class="plusminus">+</span><a href="{$html->url('/')}view/{$ticket.id}">{$ticket.title}</a></div>
            
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
                   
                   <div class="info_ticket">
                    <form action="{$html->url('/tickets/save')}" method="post" name="updateForm" id="updateForm" class="cmxform">

                    <!-- 
                        TODO salvataggio Ajax del subticket. Salvare
                        _status
                        _exp_resolution_date
                        _start_date
                        _categoria
                        _assegnatari
                    -->

                    <input type="hidden" name="data[id]" value="{$subtask.id|default:''}"/>
                        <table>
                            <tr><td colspan="2">title: {$subtask.title|default:'<i>no title</i>'}</td></tr>
                            
                            <tr>
                                <td colspan="2">
                                category: 
                                {foreach from=$subtask.Category item=cat}
                                <br /><input type='checkbox' name='data[Category][{$cat.id}]' value="{$cat.id}" checked=checked /> {$cat.label}
                                {/foreach}
                                </td>
                            </tr>

                            <tr>
                                <td>status:</td>
                                <td>
                                    <select name="data[status]">
                                    {foreach item=sta key='key' from=$conf->ticketStatus}
                                        <option value="{$key}" {if $subtask.ticket_status==$key}selected{/if}>{$key}</option>
                                    {/foreach}
                                    </select>
                                </td>
                            </tr>
                            {if !empty($subtask.User)}
                                <tr><td colspan="2">
                                    {foreach from=$subtask.User item=user}
                                        {if $user.ObjectUser.switch=="assigned"}
                                        <div class="profile">
                                           {$user.realname|truncate:2:''}
                                        </div>
                                        {/if}
                                    {/foreach}
                                </td></tr>
                                {foreach from=$subtask.User item=user}
                                <tr><td colspan="2">{$user.ObjectUser.switch}: {$user.realname}</td></tr>
                                {/foreach}
                            {/if}
                            <tr>
                                <td>start on:</td>
                                <td class="tcal start_date">
                                    {$subtask.start_date|date_format:'%a %d %b %Y'}
                                    <input type="hidden" name="data[start_date]" value="{$subtask.start_date}">
                                </td>
                            </tr>
                            <tr>
                                <td>dued on:</td>
                                <td class="tcal end_date">
                                    {$subtask.exp_resolution_date|date_format:'%a %d %b %Y'}
                                    <input type="hidden" name="data[exp_resolution_date]" value="{$subtask.exp_resolution_date}">
                                </td>
                            </tr>
                            <tr><td>duration:</td><td>{$subtask.days} days</td></tr>
                            {if !empty($subtask.closed_date)}
                            <tr>
                                <td>closed on:</td><td class="tcal">{$subtask.closed_date|date_format:'%a %d %b %Y'}</td>
                            </tr>{/if}
                            {if !empty($subtask.delay)}
                                <tr><td>delay:</td><td>{$subtask.delay} days</td></tr>
                            {/if}
                        </table>
                        <input type="submit" value="{t}save{/t}" />
                    </form>
                        <a style="margin-top:10px" class="BEbutton" href="{$html->url('/')}view/{$subtask.id}">more details</a>
                   </div>
                </div>
            {/if}
            {/foreach} 
        </div>
{/if}

{/foreach}  	
</div> <!-- closing pubb -->
</div> <!-- closing matrix -->
</div> <!-- closing timeline -->

<style scoped>

    .timeline header {
        background-image: linear-gradient(90deg, rgba(255,255,255,.3) 1px, transparent 1px);
        background-size:{$coeff*7}px {$coeff*5}px, {$coeff*7}px {$coeff*7}px, {$coeff}px {$coeff}px, {$coeff}px {$coeff}px;
    }

    .matrix {
        background-color:rgba(255,255,255,0);
        background-image: linear-gradient(white 0px, transparent 0px),
        linear-gradient(90deg, rgba(128,128,128,.2) {$coeff*2}px, transparent 1px),
        linear-gradient(rgba(255,255,255,.3) 0px, transparent 0px),
        linear-gradient(90deg, rgba(255,255,255,.3) 1px, transparent 1px);
        background-size:{$coeff*7}px {$coeff*5}px, {$coeff*7}px {$coeff*7}px, {$coeff}px {$coeff}px, {$coeff}px {$coeff}px;
        background-position: -{$coeff*2}px;
    }


     .today {
        color:red;
        position:absolute;
        margin-top:-27px;
        padding-top:20px;
        height:100%;
        padding-left:5px;
        border-left:1px solid rgba(255,0,0,1);
        margin-left:{$todayshift*$coeff}px;
     }

</style>

<script>
    $(function(){
        var movingTicket = false;

        var updateDates = function(t, ui) {
            var pos = ui.position.left;
            var dayToTime = 1000 * 60 * 60 * 24;
            var dif = dayToTime * pos / {$coeff};
            var startDate = new Date($(t).data('start')).valueOf();
            var endDate = startDate + dayToTime * $(t).width() / {$coeff};
            startDate += dif;
            endDate += dif;
            var formattedStart = moment(startDate).format('ddd DD MMM YYYY');
            var formattedEnd = moment(endDate).format('ddd DD MMM YYYY');
            $('.info_ticket .start_date', t).text(formattedStart);
            $('.info_ticket .end_date', t).text(formattedEnd);
            $('[name="data[start_date]"]', t).val( moment(startDate).format('YYYY-MM-DD HH:mm') );
            $('[name="data[exp_resolution_date]"]', t).val( moment(endDate).format('YYYY-MM-DD HH:mm') );
        }


        $( ".flowticket" ).click(function(ev) {
                var that = this;
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