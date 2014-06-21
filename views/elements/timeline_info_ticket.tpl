<div class="info_ticket  {if !empty($parent)}add_ticket{/if}">
    
    <form action="{$html->url('/tickets/save')}" method="post" name="updateForm" id="updateForm" class="cmxform">

    {if !empty($parent)}
         <div style="white-space:normal; margin-bottom:5px">
            create new subtask of
           <h2>{$parent.title|default:$parent.nickname}</h2>
        </div>

        <input type="hidden" name="data[subtask_of]" value="{$parent.id}"/>

    {else}


    {/if}


    <!-- 
        TODO salvataggio o modifica Ajax del subticket. Salvare solo quello che si vuole! senza che vengano cancellati dati preeesistenti.
    -->
  
        <table style="width:100%">
            <tr>
                <td>status:</td>
                <td>
                    <select name="data[status]">
                    {foreach item=sta key='key' from=$conf->ticketStatus}
                        <option value="{$key}" {if !empty($subtask.ticket_status) && $subtask.ticket_status==$key}selected{/if}>{$key}</option>
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
                <td>title</td>
                <td>
                    <input type="text" name="data[title]" value="{$subtask.title|default:''}" />
                </td>
            </tr>
            <tr>
                <td>category</td>
                <td>
                   <select multiple>
                    {foreach from=$categories|default:'' key=key item=cat}
                    <option value="{$key}">{$cat}</option>
                    {/foreach}
                    </select>
                {*foreach from=$subtask.Category item=cat}
                <br /><input type='checkbox' name='data[Category][{$cat.id}]' value="{$cat.id}" style="margin:0 10px 0 5px" checked=checked /> {$cat.label}
                {/foreach*}
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
        <input style="margin:0 10px 0 10px" type="submit" value="{t}save{/t}" /> 
         {if !empty($subtask)}<a style="margin:0 10px 0 10px" class="BEbutton" href="{$html->url('/')}view/{$subtask.id}">more details</a>{/if}
    </form>
        

   </div>