
package App::Editor::GVip::View ;

use strict;
use Time::HiRes qw(gettimeofday tv_interval) ;
use Data::TreeDumper ;

#------------------------------------------------------------------------------------------------------

sub configure_event 
{
my ($widget, $event, $view) = @_;

# recompute scrollbars
my $lines_in_page = int($event->height() / ($view->{INTERLINE} + $view->{FONT_HEIGHT}));

$view->{V_ADJUSTMENT}->page_increment($lines_in_page) ;
$view->{V_ADJUSTMENT}->page_size($lines_in_page) ;
$view->{V_ADJUSTMENT}->changed() ;
}

#------------------------------------------------------------------------------------------------------

my $counter = 1 ;

sub expose_event
{
my $t0 = [gettimeofday];

my ($widget, $event, $view) = @_;

my $buffer      = $view->{BUFFER} ;
my $hadjustment = int($view->{H_ADJUSTMENT}->get_value() ) ;
my $vadjustment = int($view->{V_ADJUSTMENT}->get_value() ) ;

my $buffer_lines = $buffer->GetNumberOfLines() ;

#~ $last_buffer_modification_time = $buffer->GetAttribute($widget) || 0 ;
#~ my $buffer_modified = $buffer->GetModificationTime() != $last_buffer_modification_time ;

my $top_line = $vadjustment ;
my $horizontal_offset = - ($hadjustment * $view->{FONT_WIDTH}) ;

my $alloc            = $widget->allocation;
my $lines_in_display = ($alloc->height / ($view->{INTERLINE} + $view->{FONT_HEIGHT})) + 1;

my $last_line = $top_line + $lines_in_display ;
$last_line    = $last_line > $buffer->GetLastLineIndex() ? $buffer->GetLastLineIndex() : $last_line ;

my $gc = $widget->get_style->text_gc($widget->state) ;
my $fg_color =  Gtk2::Gdk::Color->new(0, 0, 0) ;
my $bg_color = Gtk2::Gdk::Color->new(0xFFFF, 0xFFFF, 0xFFFF) ;

my $layout = $widget->create_pango_layout('');
$layout->set_font_description($view->{FONT_DESCRIPTION}) ;

for my $line ($top_line .. $last_line)
	{
	# todo
	# don't draw if not visible due to horizontal scrolling
	# draw only the changed lines
	my $x = $horizontal_offset ;
	my $y = ($view->{FONT_HEIGHT} + $view->{INTERLINE}) * ($line - $top_line) ;
	
	my $text ;
	
	# draw only the visible part
	if(exists $view->{LEXER})
		{
		#~ $color_spans = $view->{LEXER}->Lex($view->{BUFFER}, $line) ;
		$text = $view->{LEXER}->Lex($view, $line) ;
		}
	else
		{
		$text = $buffer->GetTabifiedText($line, undef, $view->{TAB_SIZE}) ;
		}
		
	# color the selection
	
	if(defined $text)
		{
		$layout->set_markup($text) ;
		
		$widget->window->draw_layout
			(
			  $gc
			, $x, $y
			, $layout
			) ;
		}
	}
	
$widget->grab_focus() ;

RefreshCaret($view) ; # caret is draw on focus-in which is called before this, we just drew over it

my $build_time = tv_interval ($t0, [gettimeofday]) ;
#~ print(sprintf("[%d] display time: %0.2f s.", $counter++, $build_time)) ;
}

#------------------------------------------------------------------------------------------------------

sub UpdateDisplay
{
my ($view) = @_ ;
$view->{TEXT_AREA}->queue_draw();
}

