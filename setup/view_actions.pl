
use strict;
use warnings ;

use Data::TreeDumper ;
use Data::TreeDumper::Renderer::GTK ;

#------------------------------------------------------------------------------------------------------

sub Init
{
my ($view) = @_ ;
my ($buffer, $actions) = ($view->GetBuffer(), $view->GetActions()) ;

# some introspection
$actions->RegisterActions([ 'Show View' => 'V', 'C0S' => \&ShowView]) ;
$actions->RegisterActions([ 'Show actions' => 'A', 'C0S' => \&ShowActions]) ;

# filter example
$actions->RegisterActions([ 'preaction filter' => 'P', 'C0S' => \&SetPreaction]) ;
$actions->RegisterActions([ 'preaction filter 1' => 'preaction filter', '1' => \&PreactionFilter1]) ;
$actions->RegisterActions([ 'preaction filter 2' => 'preaction filter', '2' => \&PreactionFilter2]) ;

#tooltip
$actions->RegisterActions([ 'Set Tooltip Text' => 'SetTooltipText', '000' => \&SetTooltipText]) ;
}

#------------------------------------------------------------------------------------------------------

sub DumpElement
{
my ($reference, $title) = @_ ;

my $treedumper = Data::TreeDumper::Renderer::GTK->new
			(
			data => $reference ,
			title => $title ,
			#~ dumper_setup => {DISPLAY_PERL_SIZE => 1, MAX_DEPTH => 4}
			);
			
$treedumper->modify_font(Gtk2::Pango::FontDescription->from_string ('monospace 9'));

#~ $treedumper->expand_all;

# some boilerplate to get the widget onto the screen...
my $window = Gtk2::Window->new;
$window->set_title($title) ;

$window->set_default_size (400, 500);
$window->signal_connect (destroy => sub { $_[0]->destroy });

my $scroller = Gtk2::ScrolledWindow->new;
$scroller->set_policy ('automatic', 'automatic');
$scroller->set_shadow_type ('in');
$scroller->add ($treedumper);

$window->add ($scroller);
$window->show_all;

#~ $treedumper->Run ;
} ;

#------------------------------------------------------------------------------------------------------

sub ShowView
{
my ($actions, $view) = @_ ;

DumpElement($view, "$view") ;
}

#------------------------------------------------------------------------------------------------------

sub ShowActions
{
my ($actions, $view) = @_ ;

DumpElement($view->{ACTIONS}, 'view actions') ;
}

#------------------------------------------------------------------------------------------------------

sub SetTooltipText
{
my ($actions, $view, $button_x, $button_y, $tooltip_text, $tooltip_extra_text) = @_ ;

$$tooltip_text = "action @ $button_x, $button_y" ;
$$tooltip_extra_text = 'position = where the cursor points at.' ;
}

#------------------------------------------------------------------------------------------------------

sub SetPreaction
{
my ($actions, $view, $button_x, $button_y, $tooltip_text, $tooltip_extra_text) = @_ ;

$actions->{PREACTION}{COMMENT} = 'some action filter example' ;
$actions->{PREACTION}{SUB} = \&ActionFiler;
}

sub ActionFiler
{
my ($actions, $action_name, @args) = @_ ;

print "filter got '$action_name'\n" ;
if($action_name eq '000p')
	{
	PreactionFilter1() ;
	}
elsif($action_name eq '000o')
	{
	PreactionFilter2() ;
	}

# wait till valid input, we could display a table after 3 tries
else
	{
	delete $actions->{PREACTION} ;
	}

# or quit on first invalid input
#~ delete $actions->{PREACTION} ;

return("preaction filter quit") ;
}

sub PreactionFilter1
{
print "PreactionFilter1\n" ;
}

sub PreactionFilter2
{
print "PreactionFilter2\n" ;
}


#------------------------------------------------------------------------------------------------------

1 ;