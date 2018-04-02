Officers
========

#### Tutoring · Advising · Leading

Our officers are here to make your undergraduate computer science
experience the best it can be. Need tutoring? Want help on a personal
project? Looking for a job? Want to find your community? Come visit us
in 311 Soda!

For a calendar view of office hours, visit our [office hours sheet](https://docs.google.com/spreadsheets/d/15kuC4Q6HmhRSt5BTQCzKbWR4dM_M9FJaazRNqBZnq1k).

<div class=grid-wrapper>
$for(officers)$
<div class=officer>
$officers.first$ $officers.last$
<img src="img/officers/$officers.first$_$officers.last$.jpg">
</div>
$endfor$
</div>

<style>
.officer {
	display: inline-block;
	width: 180px;
}
.grid-wrapper {
	display: grid;
	grid-template-columns: 200px 200px 200px;
}
</style>
