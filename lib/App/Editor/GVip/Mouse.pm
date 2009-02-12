
package App::Editor::GVip::View ;

use strict;
use Time::HiRes qw(gettimeofday tv_interval) ;
use Data::TreeDumper ;

#------------------------------------------------------------------------------------------------------

sub button_press_event
{
my ($widget, $event, $view) = @_;

my $buffer      = $view->{BUFFER} ;
my $hadjustment = int($view->{H_ADJUSTMENT}->get_value()) ;
my $vadjustment = int($view->{V_ADJUSTMENT}->get_value()) ;

if($event->button == 3)
	{
	# move this to an action
	$view->{ACTIONS}->Run('POPUP_MENU-000', $view, $event) ;
	}
else
	{
	RemoveCaret($view) ;
	
	my $top_line = $vadjustment ;
	my $horizontal_offset = -($hadjustment  * $view->{FONT_WIDTH}) ;
	
	my $button_x = int ($event->x / $view->{FONT_WIDTH})  + $horizontal_offset ;
	my $button_y = int($event->y / ($view->{FONT_HEIGHT} + $view->{INTERLINE})) ;
	
	my $character = int( ($event->x / $view->{FONT_WIDTH})  + $horizontal_offset) ;
	my $line      = int( ($event->y / ($view->{FONT_HEIGHT} + $view->{INTERLINE})) + $top_line) ;
	
	if($line <= $buffer->GetLastLineIndex())
		{
		$buffer->SetTabSize($view->{TAB_SIZE}) ;
		$buffer->SetModificationPosition($line, $buffer->GetCharacterPositionInText($line, $character)) ;
		
		UpdateDisplay($view) ;
		}
		
	AddCaret($view) ;
	$view->{CAPTURING}  = [$button_x, $button_y] ;
	$view->{POINTER_AT} = [$button_x, $button_y] ;
	
	# change cursor if ctl, shift and actions for them
	}
	
return(1) ;
}
	
#------------------------------------------------------------------------------------------------------

sub button_release_event
{
my ($widget, $event, $view) = @_;

if($view->{CAPTURING})
	{
	my $buffer      = $view->{BUFFER} ;
	my $hadjustment = int($view->{H_ADJUSTMENT}->get_value()) ;
	my $vadjustment = int($view->{V_ADJUSTMENT}->get_value()) ;
	
	my $top_line = $vadjustment ;
	my $horizontal_offset = -($hadjustment  * $view->{FONT_WIDTH}) ;
	my $button_x = int($event->x / $view->{FONT_WIDTH})  + $horizontal_offset ;
	my $button_y = int($event->y / ($view->{FONT_HEIGHT} + $view->{INTERLINE})) ;

	#~ print "release at $button_x, $button_y\n" ;
	
	delete $view->{CAPTURING} ;
	delete $view->{POINTER_AT} ;
	}
}

#------------------------------------------------------------------------------------------------------

sub motion_notify_event 
{
my ($widget, $event, $view) = @_;

my $buffer      = $view->{BUFFER} ;
my $hadjustment = int($view->{H_ADJUSTMENT}->get_value()) ;
my $vadjustment = int($view->{V_ADJUSTMENT}->get_value()) ;

my $top_line = $vadjustment ;
my $horizontal_offset = -($hadjustment  * $view->{FONT_WIDTH}) ;
my $button_x = int( ($event->x / $view->{FONT_WIDTH})  + $horizontal_offset + 0.5) ;
my $button_y = int( ($event->y / ($view->{FONT_HEIGHT} + $view->{INTERLINE}))-0.5) ;

if($view->{CAPTURING})
	{
	#~ print "$button_x, $button_y\n" ;
	if($view->{POINTER_AT}[0] != $button_x || $view->{POINTER_AT}[1] != $button_y)
		{
		$view->{POINTER_AT} = [$button_x, $button_y] ;
		#~ print "motion at $button_x, $button_y\n" ;
		
		my ($x, $y) = ($view->{CAPTURING}[0], $view->{CAPTURING}[1]) ;
		$x *= $view->{FONT_WIDTH} ;
		$y *= ($view->{FONT_HEIGHT} + $view->{INTERLINE}) ;
		
		my $width = ($button_x - $view->{CAPTURING}[0]) * $view->{FONT_WIDTH} ;
		if($width < 0)
			{
			$x += $width ;
			$width *= -1 ;
			}
			
		my $height = (($button_y - $view->{CAPTURING}[1]) + 1) * ($view->{FONT_HEIGHT} + $view->{INTERLINE}) ;
		if($height < 0)
			{
			$y += $height;
			$height *= -1 ;
			}
			
		#~ print "$x, $y, $width , $height\n" ;
		
		my $widget = $view->{TEXT_AREA} ;
		my $gc = $widget->get_style->text_gc($widget->state) ;
		
		$gc->set_rgb_fg_color(Gtk2::Gdk::Color->new(0, 0, 0)) ;
		
		$widget->window->draw_rectangle
					(
					  $gc
					, 0 # filled
					, $x, $y
					, $width , $height
					);
		}
	}
else
	{
	# ? mouse move action?
	
	# get text from action
	my $tooltip_text = "$button_x, $button_y" ;
	my $tooltip_extra_text = "current cursor position" ;
	
	use Text::Editor::Vip::Actions::Actions ;
	#~ $view->{ACTIONS}->Run('SetTooltipText-000', $view, $button_x, $button_y, \$tooltip_text, \$tooltip_extra_text) ;
	
	#~ print "$tooltip_text , $tooltip_extra_text\n" ;
	#~ use Gtk2::Tooltips ;
	my $tooltip = new Gtk2::Tooltips();
	
	#~ print DumpTree $tooltip->data_get($widget) ;

	$tooltip->set_tip($widget, $tooltip_text, $tooltip_extra_text) ;
	$tooltip->enable();
	}
}

#-----------------------------------------------------------------------------------------------------------------

1 ;