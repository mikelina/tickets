<div class="tab"><h2>{t}filters{/t}</h2></div>
<div id="ticketfilter">
	<form id="formFilter" action="{$beurl->getUrl(['page', 'dim', 'dir', 'order'])}" method="post">
		<input type="hidden" name="cleanFilter" value=""/>
		<table class="filters" style="width: 100%">
			{if !empty($view->SessionFilter)}
			<tr>
				<th><label>{t}categories{/t}:</label></th>
				<td>
					<select name="filter[category]">
						<option value="">{t}all{/t}</option>
						{foreach $categories as $catId => $catLabel}
							{strip}
							<option value="{$catId}"{if $view->SessionFilter->read('category') == $catId}selected="selected"{/if}>
								{$catLabel}
							</option>
							{/strip}
						{/foreach}
					</select>
				</td>
				<th><label>{t}on position{/t}:</label></th>
				<td colspan="4">
					<select name="filter[parent_id]" id="parent_id" class="areaSectionAssociation">
					{$beTree->option($tree, $view->SessionFilter->read('parent_id'))}
					</select>
					{if !empty($filters.treeDescendants)}
						&nbsp;<input type="checkbox" name="filter[descendants]"
							{if $view->SessionFilter->check('descendants')}checked="checked"{/if} /> <label>{t}descendants{/t}</label>
					{/if}
				</td>
			</tr>
			{/if}
			<tr style="border-top:1px solid gray">
				<th>
					<label>{t}status:{/t}</label>
				</th>
				<td colspan="5">
					<table style="width:100%">
						<tr>
							<td style="vertical-align: top">
						{assign var="prevsta" value="draft"}
						{foreach item=sta key='key' from=$conf->ticketStatus}
							{if $prevsta!=$sta}
								</td>
								<td style="vertical-align: top">
							{/if}
							<input type="checkbox" value="{$key}" name="data[status][{$key}]" class="filterTicket" rel="{$sta}" id="status_{$key}" {if (empty($filter.f_status) && $sta != "off") || !empty($filter.f_status[$key])}checked="checked"{/if}/>
							<span>{t}{$key}{/t}:</span><br />
							{$prevsta=$sta}	
						{/foreach}
						</tr>
					</table>
					

				</td>
			</tr>
			<tr>
				<th></th>
				<td colspan="5">
					&nbsp;			
					{assign var="hide_off" value=$filter.hide_status_off|default:'false'}
					<input type="checkbox" name="data[hide_status_off]" id="filterHideClosed" 
					{if ($hide_off == 'true')}checked="checked"{/if} />&nbsp;
					<label>{t}hide closed tickets{/t}: </label>
				</td>
			</tr>
			<tr style="border-top:1px solid gray">
				<th><label>{t}reporter{/t}:</label></th>
				<td>
					<select name="data[reporter]" class="filterTicket">
						<option value="">all</option>
						{foreach item=reporter key='key' from=$reporters}
						<option value="{$reporter.User.id}" {if (!empty($filter.f_reporter) && ($filter.f_reporter == $reporter.User.id))}selected="selected"{/if}>{$reporter.User.userid}</option>
						{/foreach}
					</select>
				</td>
				<th><label>{t}assigned to{/t}:</label></th>
				<td>
					<select name="data[assigned_to]" class="filterTicket">
						<option value="">all</option>
						{foreach item=user key='key' from=$assignedUsers}
						<option value="{$user.User.id}" {if !empty($filter.f_assigned_to) && $filter.f_assigned_to == $user.User.id}selected="selected"{/if}>{$user.User.userid}</option>
						{/foreach}
					</select>
				</td>
				<th><label>{t}severity{/t}:</label></th>
				<td>
					<select name="data[severity]" id="ticketSev" class="filterTicket">
						<option value="">all</option>
					{foreach item=sev from=$conf->ticketSeverity}
						<option value="{$sev}" {if (!empty($filter.f_severity) && ($filter.f_severity == $sev))}selected="selected"{/if}>{$sev}</option>
					{/foreach}
					</select>
				</td>
			</tr>
			<tr style="border-top:1px solid gray">
				<th></th>
				<td colspan="10" style="padding-top:10px">
					<input type="submit" id="searchButton" style="width:150px" value=" {t}find it{/t} ">
					<input type="button" id="cleanFilters" value=" {t}reset filters{/t} ">
				</td>
			</tr>
		</table>
	</form>
</div>
