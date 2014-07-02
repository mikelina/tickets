<div class="info_ticket  {if !empty($parent)}add_ticket{/if}">
    
    <form action="{$html->url('/pages/saveQuickItem')}" method="post" name="updateForm" class="cmxform">

    {if !empty($parent)}
         <div style="white-space:normal; margin-bottom:5px">
            create new subtask of
           <h2>{$parent.title|default:$parent.nickname}</h2>
        </div>

        <input type="hidden" name="data[RelatedObject][subtask_of][$parent.id][id]" value="{$parent.id}"/>

    {else}


    {/if}


    <!-- 
        TODO salvataggio o modifica Ajax del subticket. Salvare solo quello che si vuole! senza che vengano cancellati dati preeesistenti.
    -->
  
        <table style="width:100%">
            <tr>
                <td>status:</td>
                <td>
                    <select name="data[ticket_status]">
                    {foreach item=sta key='key' from=$conf->ticketStatus}
                        <option value="{$key}" {if !empty($subtask.ticket_status) && $subtask.ticket_status==$key}selected{/if}>{$key}</option>
                    {/foreach}
                    </select>
                    <input type="hidden" name="data[status]" value="{$subtask.status|default:''}"/>
                </td>
            </tr>

            {if !empty($subtask.User.assigned)}
                <tr>
                    <td colspan="2">
                    {foreach $subtask.User.assigned as $userId => $user}
                        <div class="profile">
                           {$user.realname|truncate:2:''}
                        </div>
                    {/foreach}
                    </td>
                </tr>
            {/if}

            {if !empty($subtask.User.notify)}
                {foreach $subtask.User.notify as $user}
                <tr><td colspan="2">notify: {$user.realname}</td></tr>
                {/foreach}
            {/if}
            <tr>
                <td>title</td>
                <td>
                    <input type="text" name="data[title]" value="{$subtask.title|default:''}" />
                </td>
            </tr>
            <tr>
                <td>category</td>
                <td>
                   <select multiple name="data[Category][]">
                    {foreach from=$categories|default:'' key=key item=cat}
                    <option value="{$key}"{foreach $subtask.Category|default:[] as $c}{if $c.id == $key} selected{/if}{/foreach}>{$cat}</option>
                    {/foreach}
                    </select>
                </td>
            </tr>
            <tr>
                <td>start on:</td>
                <td class="tcal start_date">
                    <input type="text" class="dateinput" name="data[start_date]" value="{if !empty($subtask)}{$subtask.start_date|date_format:$conf->datePattern|default:''}{/if}">
                </td>
            </tr>
            <tr>
                <td>dued on:</td>
                <td class="tcal end_date">
                    <input type="text" class="dateinput" name="data[exp_resolution_date]" value="{if !empty($subtask)}{$subtask.exp_resolution_date|date_format:$conf->datePattern|default:''}{/if}">
                </td>
            </tr>
        {if !empty($subtask)}
            {if !empty($subtask.closed_date)}
            <tr>
                <td>closed on:</td><td class="tcal">{$subtask.closed_date|date_format:'%a %d %b %Y'}</td>
            </tr>
            {/if}
            <tr><td>duration:</td><td><span class="durate-field">{$subtask.days}</span> days</td></tr>
            {if !empty($subtask.delay)}
                <tr><td>delay:</td><td>{$subtask.delay} days</td></tr>
            {/if}
        {/if}
        </table>
        <hr />

        {* hidden assigned users (it needs for notification) *}
        <input type="hidden" name="data[users][assigned]" value="{if !empty($subtask.User.assigned)}{foreach from=$subtask.User.assigned item='u' name='user'}{$u.id}{if !$smarty.foreach.user.last},{/if}{/foreach}{/if}"/>

        {* hidden notified users (it needs for notification) *}
        <input type="hidden" name="data[users][notify]" value="{if !empty($subtask.User.notify)}{foreach from=$subtask.User.notify item='u' name='user'}{$u.id}{if !$smarty.foreach.user.last},{/if}{/foreach}{elseif empty($subtask)}{$BEAuthUser.id}{/if}"/>

        <input type="hidden" name="data[object_type_id]" value="{$subtask.object_type_id|default:$conf->objectTypes.ticket.id}"/>
        <input style="margin:0 10px 0 10px" type="submit" value="{t}save{/t}" />
        {if !empty($subtask)}
            <input type="hidden" name="data[id]" value="{$subtask.id}"/>
            <a style="margin:0 10px 0 10px" class="BEbutton" href="{$html->url('/')}view/{$subtask.id}">more details</a>
        {/if}
    </form>
        

   </div>