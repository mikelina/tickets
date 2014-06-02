{$coeff=20}

<style scoped>

    .timeline {
        overflow: hidden;
    }

    .timeline header {
        background-image: 
        linear-gradient(90deg, rgba(255,255,255,.3) 1px, transparent 1px);
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

    .matrix .mainticket {
        margin-bottom:{$coeff}px; width:100%
    }

    .matrix .mainticket .thead {
        background-color:rgba(255,255,255,1); 
        display:block; 
        height:{$coeff}px;
        padding-left:5px;
        box-shadow: 0 0 10px rgba(0,0,0,0.2);
        position:relative;
        z-index:800
     }

    .matrix .mainticket .thead .plusminus {
        display: inline-block;
        text-align: right;
        padding-left: 0px;
        padding-right: 10px;
        cursor: pointer;
    }

    .flowticket {
        margin-top:0px;
        background-color:pink; 
        font-weight: normal;
        height:{$coeff}px;
        opacity:1;
        font-size:12px;
        color:white !important;
        padding-left:5px;
        box-shadow: 0 0 10px rgba(0,0,0,0.1) inset;
    }

    .flowticket.analysis { background-color: #cc6666 }
    .flowticket.tagging  { background-color: #ff9900 }
    .flowticket.editing { background-color: #99cc66 }
    .flowticket.checking  { background-color: #6e9bed }
    .flowticket.revision  { background-color: #3d82c7 }
    .flowticket.release  { background-color: #073564 }

    .flowticket.resolved  { }
/*
.flowticket.overdelayed  {
    background: 
    linear-gradient(135deg, red 25%, transparent 25%) -50px 0,
    linear-gradient(225deg, red 25%, transparent 25%) -50px 0,
    linear-gradient(315deg, red 25%, transparent 25%),
    linear-gradient(45deg, red 25%, transparent 25%);   
    background-size: 20px 20px;
}
*/
    .matrix .mainticket.closed  {
        margin-bottom:0px;
    }

    .matrix .mainticket.closed .thead {
        margin-bottom:{$coeff}px;
    }

    .matrix .mainticket.closed .flowticket {
        margin-top:-{$coeff}px;
        opacity:.5;
        color:transparent !important;
    }

    .matrix .mainticket.closed .flowticket * {
        display:none;
    }

    .info_ticket {
        display:none;
        width:200px;
        color:#FFF;
        background-color: #444;
        position:absolute;
        padding:10px;
        z-index: 900;
        margin-left: -5px;
        margin-top: 2px;
    }

    .flowticket .ncomments {
        display: inline-block;
        width:16px;
        height:16px;
        line-height: 16px;
        font-size: 11px;
        background-color: black;
        border-radius: 100%;
        text-align: center;
        margin:0px 0px 0px 4px;
    }

    .info_ticket .profile {
        width:50px;
        height:50px;
        border-radius: 100%;
        background-color: #666;
        font-size: 24px;
        text-align: center;
        line-height: 0;
        padding-top:24px;
        display: inline-block;
        margin: 5px 5px 5px 0px
    }

    .info_ticket TR {
        white-space: nowrap;
        border-top:1px solid rgba(255,255,255,.1);
        padding:2px; 
        margin:2px;
    }

     .info_ticket TR:first-child {
        border:0px;
     }

     TD.tcal {
        text-align: right;
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

        $( ".flowticket" ).hover(
          function(e) {
             $(".info_ticket",this ).fadeIn( 100 );
          }, function() {
            $(".info_ticket",this ).fadeOut( 100 );
          }
        );

        $(".thead").click(function(){
            $(this).closest(".mainticket").toggleClass("closed");
        });

    });
</script>

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
            {$assigned = array()}
            
                <div class="flowticket {$subtask.Category.0.name|default:''} {$subtask.ticket_status}" 
                style="margin-left:{$subtask.shift*$coeff}px; width:{$subtask.days*$coeff}px; border-right:{$subtask.delay*$coeff}px solid rgba(255,0,0,.5)">
                   
                   {$subtask.Category.0.name|default:''} <!-- {$subtask.ticket_status|default:''} -->
                   
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
                            {if !empty($subtask.start_date)}<tr><td>start on:</td><td class="tcal">{$subtask.start_date|date_format:'%a %d %b %Y'}</td></tr>{/if}
                            {if !empty($subtask.exp_resolution_date)}<tr><td>dued on:</td><td class="tcal">{$subtask.exp_resolution_date|date_format:'%a %d %b %Y'}</td></tr>{/if}
                            {if !empty($subtask.closed_date)}<tr><td>closed on:</td><td class="tcal">{$subtask.closed_date|date_format:'%a %d %b %Y'}</td></tr>{/if}
                            
                            {if $subtask.delay > 0}
                                <tr><td>delay:</td><td>{$subtask.delay|default:''} days</td></tr>
                            {/if}
                        </table>
                        <input type="submit" value="{t}save{/t}" />
                    </form>
                        <a style="margin-top:10px" class="BEbutton" href="{$html->url('/')}view/{$subtask.id}">more details</a>
                   </div>
                </div>
           
            {/foreach} 
        </div>
{/if}

{/foreach}  	
</div> <!-- closing pubb -->
</div> <!-- closing matrix -->
</div> <!-- closing timeline -->


{*dump var=$tickets|default:''*}