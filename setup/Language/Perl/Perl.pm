
package Lexer::Perl ;

use strict ;
use warnings ;
use Carp ;

$|++ ;

use Data::TreeDumper ;
use Text::Editor::Vip::Color::Color ;

#-------------------------------------------------------------------------------

sub new
{
my $invocant = shift ;
my $directory = shift ;

my $class = ref($invocant) || $invocant ;
my $object_reference = bless {}, $class ;

$object_reference->Setup($directory) ;

return($object_reference) ;
}

#-------------------------------------------------------------------------------

sub Setup
{
my $this = shift ;
my $directory = shift ;

my($colors, $color_classes, $keyword_to_colors) =
	GetKeywordColors
		(
		  COLORS => ["$directory/Colors/default_colors.pm", "$directory/Language/Perl/PerlColors.pm"]
		, COLORS_AND_KEYWORDS => ["$directory/Language/Perl/PerlKeywords.pm"]
		, KEYWORDS => []
		, MAPPING => 'pango'
		, USE_X_COLORS => 1
		) ;

$this->{LEXER}{KEYWORD_TO_COLOR} = $keyword_to_colors ;
$this->{LEXER}{DEFAULT_COLOR}    = $color_classes->{default} ;
$this->{LEXER}{UPPER_CASE_COLOR} = $color_classes->{upper_case_alphanumeric_identifier} ;
}

#-------------------------------------------------------------------------------

sub Lex
{
my ($this, $view, $line) = @_ ;

my $string = $view->GetBuffer()->GetTabifiedText($line, undef, $view->{TAB_SIZE}) ;

my $colorized_string ;

for (split /([^a-zA-Z_0-9\$\@\%\:\/\\=~]+)/, $string)
	{
	# TODO: do not make multiple elements if the color is the same
	
	if(exists $this->{LEXER}{KEYWORD_TO_COLOR}{$_})
		{
		$colorized_string .= $this->{LEXER}{KEYWORD_TO_COLOR}{$_} .  $_  . '</span>' ;
		}
	else
		{
		if(/^[A-Z_]+$/)
			{
			$colorized_string .= $this->{LEXER}{UPPER_CASE_COLOR} .  $_  . '</span>' ;
			}
		else
			{
			$colorized_string .= $this->{LEXER}{DEFAULT_COLOR} .  $_  . '</span>'
			} 
		}
	}
	
return($colorized_string) ;
}

#-------------------------------------------------------------------------------

1 ;
