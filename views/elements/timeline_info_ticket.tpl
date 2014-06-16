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
        <table style="width:100%">
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
            <tr><td colspan="2">title: {$subtask.title|default:'<i>no title</i>'}</td></tr>
            
            <tr>
                <td colspan="2">
                category: 
                {foreach from=$subtask.Category item=cat}
                <br /><input type='checkbox' name='data[Category][{$cat.id}]' value="{$cat.id}" style="margin:0 10px 0 5px" checked=checked /> {$cat.label}
                {/foreach}
                </td>
            </tr>
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
            {if !empty($subtask.closed_date)}
            <tr>
                <td>closed on:</td><td class="tcal">{$subtask.closed_date|date_format:'%a %d %b %Y'}</td>
            </tr>
            {/if}
            <tr><td>duration:</td><td>{$subtask.days} days</td></tr>
            {if !empty($subtask.delay)}
                <tr><td>delay:</td><td>{$subtask.delay} days</td></tr>
            {/if}
        </table>
        <hr />
        <input type="submit" value="{t}save{/t}" /> <a style="margin-left:10px" class="BEbutton" href="{$html->url('/')}view/{$subtask.id}">more details</a>
    </form>
        

   </div>