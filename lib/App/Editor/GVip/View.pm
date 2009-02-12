
package App::Editor::GVip::View ;

use strict;
use Time::HiRes qw(gettimeofday tv_interval) ;
use Data::TreeDumper ;

#~ use lib '.' ; # comment out to use mockup
use Text::Editor::Vip::Buffer ;
use Text::Editor::Vip::Actions ;

use App::Editor::GVip::Draw ;
use App::Editor::GVip::Caret ;
use App::Editor::GVip::Mouse ;
use App::Editor::GVip::Keyboard ;
use App::Editor::GVip::Scrollbars ;

use Glib ':constants';
use Gtk2 -init;
use Gtk2::Pango;
use Gtk2::Gdk::Keysyms ;

my $default_font_height = 10 ;

sub new
{
my ($class, $buffer) = @_ ;

#-----------------------------------
# the editor data
#-----------------------------------
my $view = 
	{
	  BUFFER              => $buffer
	, ACTIONS             => new Text::Editor::Vip::Actions()
	
	, FONT_FAMILLY        => 'Monospace'
	, FONT_HEIGHT         => $default_font_height
	, FONT_WIDTH          => undef #computed later
	, FONT_DESCRIPTION    => undef #computed later
	, INTERLINE           => $default_font_height / 2
	, HORIZONTAL_SCROLL   => 15
	, TAB_SIZE            => 4
	, CARET_BLINK_PERIODE => 500
	, CARET_WIDTH         => 2
	} ;
	
#-----------------------------------
# text_area + scrollbars
#-----------------------------------
my $composite_widget = new Gtk2::Table(2, 2, 0);

#-----------------------------------
# text area
#-----------------------------------
my $text_area = Gtk2::DrawingArea->new;
$text_area->can_focus(TRUE) ;

$text_area->modify_bg('GTK_STATE_NORMAL', Gtk2::Gdk::Color->new (0xFFFF ,0xFFFF ,0xFFFF)) ;

$composite_widget->attach_defaults($text_area, 0 , 1, 0, 1) ;

#-----------------------------------
# horizontal scrollbar
#-----------------------------------
my $hadjustment = Gtk2::Adjustment->new(0, 0, 500,  1, $view->{HORIZONTAL_SCROLL}, $view->{HORIZONTAL_SCROLL}) ;
$hadjustment->signal_connect("value_changed", \&Signal_ScrollBar, $view);

$composite_widget->attach
	(
	Gtk2::HScrollbar->new($hadjustment),
	0, 1, 1, 2,
        ['fill'], [], 0, 0
	);

#-----------------------------------
# vertical scrollbar
#-----------------------------------
my $vadjustment = Gtk2::Adjustment->new(0, 0, $buffer->GetNumberOfLines(),  1, 15, 15) ;
$vadjustment->signal_connect("value_changed", \&Signal_ScrollBar, $view);

$composite_widget->attach
	(
	Gtk2::VScrollbar->new($vadjustment),
	1, 2, 0, 1,
        [], ['fill'], 0, 0
	);

#-----------------------------------
# add the UI parts
#-----------------------------------
%$view = 
	(
	  %$view
	, WIDGET              => $composite_widget
	, TEXT_AREA           => $text_area
	, H_ADJUSTMENT        => $hadjustment
	, V_ADJUSTMENT        => $vadjustment
	) ;

SetupFont($view) ;

#-----------------------------------
# callbacks
#-----------------------------------
$text_area->add_events([ qw( key-press-mask button-press-mask button-release-mask pointer-motion-mask) ]) ;

my %callbacks =
	(
	'configure_event'      => \&configure_event     ,
	'expose_event'         => \&expose_event        ,
	'scroll_event'         => \&scroll_event        ,
	'button_press_event'   => \&button_press_event  ,
	'button_release_event' => \&button_release_event,
	'key_press_event'      => \&key_press_event     ,
	'motion_notify_event'  => \&motion_notify_event ,
	'focus-in-event'       => \&focus_in_event      ,
	'focus-out-event'      => \&focus_out_event     ,
	) ;
	
for my $callback_name (keys %callbacks)
	{
	$text_area->signal_connect($callback_name => $callbacks{$callback_name}, $view) ;
	}

return(bless($view, $class)) ;
}

#------------------------------------------------------------------------------------------------------

sub GetActions
{
my ($self) = @_ ;
return($self->{ACTIONS}) ;
}

sub SetActions
{
my ($self, $actions) = @_ ;
$self->{ACTIONS} = $actions ;
}

#------------------------------------------------------------------------------------------------------

sub GetBuffer
{
my ($self) = @_ ;
return($self->{BUFFER}) ;
}

#------------------------------------------------------------------------------------------------------

sub focus_in_event 
{
my ($widget, $event, $view) = @_ ;
#~ print "focus-in-event\n" ;
AddCaret($view) 
}

#------------------------------------------------------------------------------------------------------

sub focus_out_event
{
my ($widget, $event, $view) = @_ ;
#~ print "focus-out-event\n" ;
RemoveCaret($view) ;
}

#------------------------------------------------------------------------------------------------------

sub SetupFont
{
my ($view) = @_ ;

my $widget = $view->{TEXT_AREA} ;

$view->{FONT_DESCRIPTION} = Gtk2::Pango::FontDescription->from_string("$view->{FONT_FAMILLY} $view->{FONT_HEIGHT}") ;
my $char_layout = $widget->create_pango_layout ('M');
$char_layout->set_font_description($view->{FONT_DESCRIPTION}) ;

($view->{FONT_WIDTH}, undef) = $char_layout->get_pixel_size();
}

#------------------------------------------------------------------------------------------------------

sub DisplayMessage
{
my ($window, $message) = @_ ;

my $dialog = Gtk2::MessageDialog->new 
	(
	$window,
	'destroy-with-parent' ,
	'info' ,
	'close' ,
	$message ,
	) ;

$dialog->signal_connect(response => sub { $dialog->destroy ; 1 }) ;
$dialog->show() ;
}

#------------------------------------------------------------------------------------------------------
1 ;
