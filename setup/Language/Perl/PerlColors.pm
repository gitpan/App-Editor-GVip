
my $rgb =
	{
	olive_green      => [202, 255, 112] ,
	dark_olive_green => [110, 139,  61] , 
	light_blue       => [191, 239, 255] ,
	steel_blue       => [ 79, 148, 205] , 
	pastel_turquoise => [175, 238, 238] ,
	} ;
	

my $color_class =
	{
	unwanted_separator                            => ['black', 'cyan'],
	upper_case_alphanumeric_identifier            => ['default_bg', 'dark_red'],
	escaped_char                                  => ['yellow', 'red'],
	new_line                                      => ['default_bg', 'default_fg'],
	single_character                              => ['red', 'white'],
	separator                                     => ['default_bg', 'default_fg'],
	spaces                                        => ['default_bg', 'default_fg'],
	NULL                                          => ['white', 'red'],
	reference                                     => ['cyan', 'black'],
	dereference                                   => ['yellow', 'black'],
	glob_reference                                => ['black', 'cyan'],
	glob_dereference                              => ['yellow', 'red'],
	function_prototype                            => ['orange', 'white'],
	single_quoted_string_start                    => ['light_grey', 'blue'],
	
	#q
	q_single_quoted_string_start                  => ['light_grey', 'blue'],
	double_quoted                                 => ['white', 'blue'],
	
	# `xx`
	back_quoted_string_start                      => ['yellow', 'red'],
	
	# qx
	back_quote                                    => ['yellow', 'red'],
	
	#qx'
	no_interpolation_back_quote                   => ['yellow', 'dark_green'],
	
	#qw
	extract_from_string                           => ['blue', 'white'],
	
	# qr
	quote_as_regular_expression                   => ['magenta', 'white'],
	
	# qr'
	single_quote_as_regular_expression            => ['green', 'red'],
	
	single_line_comment                           => ['white', 'grey'],
	string_start                                  => ['default_bg', 'blue'],
	
	multiple_next_line                            => ['blue', 'white'],
	multi_line_string_start                       => ['steel_blue', 'white'],
	multi_line_string_double_quote_start          => ['steel_blue', 'white'],
	multi_line_string_quote_start                 => ['grey', 'light_blue'],
	multi_line_string_execute_start               => ['yellow', 'red'],
	
	multi_line_string                             => ['light_blue', 'black'],
	multi_line_string_double_quote                => ['light_blue', 'black'],
	multi_line_string_quote                       => ['light_grey', 'blue'],
	multi_line_string_execute                     => ['pastel_yellow', 'red'],
	multi_line_interpolated_identifier            => ['light_blue', 'red'],
	
	multi_line_string_end                         => ['steel_blue', 'white'],
	multi_line_string_double_quote_end            => ['steel_blue', 'white'],
	multi_line_string_quote_end                   => ['grey', 'light_blue'],
	multi_line_string_execute_end                 => ['yellow', 'red'],
	
	match                                         => ['pastel_blue', 'default_fg'],
	substitution                                  => ['pastel_green', 'default_fg'],
	translate                                     => ['pastel_green', 'default_fg'],
	translate_tr                                  => ['pastel_green', 'default_fg'],
	match_options                                 => ['dark_yellow', 'default_fg'],
	
	substitution_options                          => ['dark_yellow', 'default_fg'],
	qr_options                                    => ['dark_yellow', 'default_fg'],
	translate_options                             => ['dark_yellow', 'default_fg'],
	
	substitution_comment                          => ['grey', 'light_grey'],
	match_interpolated_identifier                 => ['pastel_blue', 'red'],
	substitution_interpolated_identifier          => ['pastel_green', 'red'],
	string_interpolated_identifier                => ['blue', 'white'],
	back_quoted_string_interpolated_identifier    => ['light_blue', 'red'],
	qq_interpolated_identifier                    => ['blue', 'white'],
	qr_interpolated_identifier                    => ['pastel_green', 'red'],
	qx_interpolated_identifier                    => ['light_blue', 'red'],
	regex_character_class                         => ['violet', 'yellow'],
	regex_negated_character_class                 => ['violet', 'cyan'],
	regex_match_count                             => ['pastel_turquoise', 'dark_red'],
	regex_non_greedy_match_count                  => ['green', 'black'],
	regex_quantifier                              => ['pastel_green', 'dark_red'],
	regex_non_greedy_quantifier                   => ['green', 'black'],
	regex_dot_star                                => ['red', 'yellow'],
	regex_or                                      => ['green', 'black'],
	regex_anchor                                  => ['green', 'violet'],
	regex_parenthesis                             => ['red', 'white'],
	regex_non_capturing_parenthesis               => ['cyan', 'black'],
	regex_non_capturing_parenthesis_with_option   => ['cyan', 'red'],
	regex_positiv_lookahead                       => ['black', 'green'],
	regex_negativ_lookahead                       => ['black', 'red'],
	regex_lookbehind                              => ['magenta', 'white'],
	regex_negativ_lookbehind                      => ['magenta', 'black'],
	regex_code                                    => ['blue', 'cyan'],
	regex_independent_expression                  => ['blue', 'yellow'],
	regex_non_sense_after_match_variable          => ['red', 'black'],
	regex_inlined_options                         => ['dark_yellow', 'default_fg'],
	regex_comment                                 => ['pastel_blue', 'medium_dark_grey'],
	substitution_regex_comment                    => ['pastel_green', 'medium_dark_grey'],
	case_special_case                             => ['orange', 'blue'],
	
	# /xxxx/
	default_match_delimiter                       => ['default_bg', 'dark_red'],
	
	# m#xxx#
	match_delimiter                               => ['red', 'white'],
	
	# m?xxx?
	match_only_once_delimiter                     => ['cyan', 'blue'],
	
	# m'xxx'
	no_interpolation_match_delimiter              => ['green', 'red'],
	substitution_delimiter                        => ['blue', 'yellow'],
	
	#                                             => ['s'xx'yy'', ''],
	no_interpolation_substitution_delimiter       => ['green', 'red'],
	translate_delimiter                           => ['red', 'blue'],
	translate_tr_delimiter                        => ['red', 'white'],
	pod_doc                                       => ['light_grey', 'black'],
	pod_doc_non_recognized_command                => ['grey', 'yellow'],
	file_test                                     => ['blue', 'yellow'],
	pragma                                        => ['red', 'white'],
	perceps_short_comment                         => ['light_grey', 'default_bg'],
	perceps_long_comment                          => ['light_grey', 'default_bg'],
	keyword_command                               => ['red', 'white'],
	button                                        => ['red', 'white'],
	} ;


return($rgb, $color_class) ;
