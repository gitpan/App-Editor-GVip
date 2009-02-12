
package App::Editor::GVip::View ;

use strict;
use Time::HiRes qw(gettimeofday tv_interval) ;
use Data::TreeDumper ;

#------------------------------------------------------------------------------------------------------

sub BlinkCaret
{
my ($view) = @_ ;

if(exists $view->{CARET_BACKUP})
	{
	RemoveCaretFromDisplay($view) ;
	}
else
	{
	AddCaretToDisplay($view) ;
	}
	
return(1) ; # continue calling
}

#------------------------------------------------------------------------------------------------------

sub RefreshCaret
{
my ($view) = @_ ;

if($view->{CARET_BACKUP})
	{
	# draw it again
	my $widget = $view->{TEXT_AREA} ;

	my ($caret_x, $caret_y, $caret_width, $caret_height) = GetCaretInfo($view) ;
	
	return if ($caret_x < 0 || $caret_y <0) ; #assertion in gtk 
	
	my $gc = $widget->get_style->text_gc($widget->state) ;
	
	$gc->set_rgb_fg_color(Gtk2::Gdk::Color->new(0, 0, 0)) ;
	
	$widget->window->draw_rectangle
				(
				  $gc
				, 1 # filled
				, $caret_x, $caret_y
				, $caret_width, $caret_height
				);
	}
}

#------------------------------------------------------------------------------------------------------

sub AddCaret
{
my ($view) = @_ ;

unless(exists $view->{CARET_TIMER_ID})
	{
	$view->{CARET_TIMER_ID} = Glib::Timeout->add($view->{CARET_BLINK_PERIODE}, \&BlinkCaret, $view) ;
	AddCaretToDisplay($view) ;
	}
}

#------------------------------------------------------------------------------------------------------

sub AddCaretToDisplay
{
my ($view) = @_ ;

my $widget = $view->{TEXT_AREA} ;
return unless $widget->realized() ;

return if exists $view->{CARET_BACKUP} ;

my ($caret_x, $caret_y, $caret_width, $caret_height) = GetCaretInfo($view) ;

return if ($caret_x < 0 || $caret_y <0) ; #assertion in gtk 

my $gc = $widget->get_style->text_gc($widget->state) ;

$view->{CARET_BACKUP} = $widget->window->get_image
					(
					  $caret_x, $caret_y
					, $caret_width, $caret_height
					) ;
		
$gc->set_rgb_fg_color(Gtk2::Gdk::Color->new(0, 0, 0)) ;

$widget->window->draw_rectangle
			(
			  $gc
			, 1 # filled
			, $caret_x, $caret_y
			, $caret_width, $caret_height
			);
}

#------------------------------------------------------------------------------------------------------

sub RemoveCaret
{
my ($view) = @_ ;

if(exists $view->{CARET_TIMER_ID})
	{
	Glib::Source->remove($view->{CARET_TIMER_ID}) ;
	RemoveCaretFromDisplay($view) ;
	delete $view->{CARET_TIMER_ID} ;
	}
}
#------------------------------------------------------------------------------------------------------

sub RemoveCaretFromDisplay
{
my ($view) = @_ ;

return unless exists $view->{CARET_BACKUP} ;

my ($caret_x, $caret_y, $caret_width, $caret_height) = GetCaretInfo($view) ;

return if ($caret_x < 0 || $caret_y <0) ; #assertion in gtk 

my $widget = $view->{TEXT_AREA} ;
my $gc = $widget->get_style->text_gc($widget->state) ;

$widget->window->draw_image
			(
			  $gc
			, $view->{CARET_BACKUP}
			, 0, 0
			, $caret_x, $caret_y
			, $caret_width, $caret_height
			) ;
			
delete $view->{CARET_BACKUP} ;
}

#------------------------------------------------------------------------------------------------------

sub GetCaretInfo
{
my ($view) = @_ ;

my $buffer = $view->{BUFFER} ;
my ($line, $character) = $buffer->GetModificationPosition() ;

$character = $buffer->GetCharacterDisplayPosition($line, $character) ;

my $top_line = int($view->{V_ADJUSTMENT}->get_value()) ;
my $horizontal_offset = int($view->{H_ADJUSTMENT}->get_value());

my $total_font_height = ($view->{FONT_HEIGHT} + $view->{INTERLINE}) ;
my $caret_x = ($character - $horizontal_offset) * $view->{FONT_WIDTH} ;
my $caret_y = $total_font_height * ($line - $top_line) ;

return($caret_x, $caret_y,  $view->{CARET_WIDTH}, $total_font_height) ;
}

1 ;