<style scoped>


</style>

<div style="width:640px">
{foreach from=$objects item=obj}
		
		{$start=$obj.created|getUnixTimestamp}
		{$end=$obj.modified|getUnixTimestamp}
		{$delta=$end-$start}
		{$days=$delta/86400}
		<div class="flowticket" style="background-color:pink; width:{$days|ceil}%">
			{$days|ceil}
		</div>
		{$start=0}
		{$end=0}
		{$delta=0}
		{$days=0}
{/foreach}		
</div>


{dump var=$objects}