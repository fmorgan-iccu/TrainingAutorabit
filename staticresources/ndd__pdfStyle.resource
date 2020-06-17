@page{
	@bottom-right {
		content: "Page " counter(page) " of " counter(pages);
	}
}
.page-break {
	display:block;
	page-break-after:always;
}
table{
	width: 100%;
	border: 1px solid black;
	border-collapse: collapse;
}
th{
	height: 30px;
}
th, td {
	border-bottom: 1px dashed #ddd;
}
table tr td.leftColumn{
	width: 20%;
	font-weight: bold;
}
table tr.underline td {
	border-bottom:1px solid black;
}
#packageTable {
	margin: 0 0px 50px 0;
}