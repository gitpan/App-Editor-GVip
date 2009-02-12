
package App::Editor::GVip::View ;

use strict;
use Time::HiRes qw(gettimeofday tv_interval) ;
use Data::TreeDumper ;

sub scroll_event
{
my($widget, $event, $view) = @_ ;

# handle this through actions
if($event->direction eq 'down')
	{
	my $current_value = int($view->{V_ADJUSTMENT}->value()) ;
	
	unless($current_value == $view->{BUFFER}->GetNumberOfLines())
		{
		$view->{V_ADJUSTMENT}->set_value($current_value + 1) ;
		}
	}
else
	{
	my $current_value = int($view->{V_ADJUSTMENT}->value()) ;
	
	unless($current_value == 0)
		{
		$view->{V_ADJUSTMENT}->set_value($current_value - 1) ;
		}
	}

UpdateDisplay($view) ;
}
	
sub Signal_ScrollBar
{
my ($adjustment, $view) = @_ ;

UpdateDisplay($view) ;
}

1 ;
