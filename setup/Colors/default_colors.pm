
my $colors =
	{
	  default_fg => 'black'
	, default_bg => 'white'
	, margin => [235, 235, 235]
	, dark_red => [110, 0, 0]
	, very_dark_red => [90, 0, 0]
	, pastel_blue => [240, 255, 255]
	, dark_blue => [0, 0, 110]
	, light_grey => [240, 240, 240]
	, dark_yellow => [238, 238, 0]
	, pastel_yellow => [255, 250, 205]
	, french_blue => [0, 0, 205]
	, medium_grey => [170, 170, 170]
	, pastel_green => [152, 251, 152]
	, medium_dark_grey => [99, 99, 99]
	, very_dark_green => [0, 50, 0]
	} ;

my $color_class =
	{
	  default             => ['default_bg',      'default_fg']
	, selection           => ['dark_blue',       'white']
	, fold_head           => ['yellow',          'blue']
	
	, margin              => ['light_grey',       'black']
	, margin_original     => ['light_grey',       'black']
	, margin_waiting      => ['blue',             'yellow']
	, margin_working      => ['red',              'yellow']
	, margin_record_macro => ['red',              'yellow']
	
	, page                => ['medium_grey',      'medium_grey']
	, page_limit          => ['dark_red',         'white']
	, out_limit           => ['red',              'default_fg']
	
	, element_debugging   => ['green',            'white']
	, element_debugging_2 => ['red',              'black']
	
	, tab1                => ['green',            'green']
	, tab2                => ['yellow',           'yellow']
	, tab3                => ['medium_grey',      'medium_grey']
	, tab4                => ['orange',           'orange']
	, tab5                => ['cyan',             'cyan']
	} ;
	
return($colors, $color_class) ;
