
package App::Editor::GVip ;

use strict;
use warnings ;
use Carp qw(carp croak confess) ;

BEGIN 
{
use Sub::Exporter -setup => 
	{
	exports => [ qw() ],
	groups  => 
		{
		all  => [ qw() ],
		}
	};
	
use vars qw ($VERSION);
$VERSION     = '0.01_01';
}

#-------------------------------------------------------------------------------

use English qw( -no_match_vars ) ;

use Readonly ;
Readonly my $EMPTY_STRING => q{} ;

use Time::HiRes qw(gettimeofday tv_interval) ;
use Data::TreeDumper ;
use File::Spec ;
use File::Basename ;

use Glib ':constants';
use Gtk2 -init;
use Gtk2::Pango;

use base 'Gtk2::Window' ;

#-------------------------------------------------------------------------------

=head1 NAME

App::Editor::GVip - gnome interface to Text::Editor::Vip

=head1 SYNOPSIS

  use Gtk2 -init ;
  my $editor_app = App::Editor::GVip->new(SETUP_PATH => $setup_path) ;  
  
  #~ $editor_app->AddView('gvip.pl') ; # open a file
  $editor_app->AddView() ;
  
  $editor_app->show_all();
  Gtk2->main();

=head1 DESCRIPTION

gnome fromt end to Text::Editor::Vip

=head1 DOCUMENTATION

This is a module I played with a few years ago. I upload it as an example of a gnome application using a CPAN module
as a back end. The editor itself is not functional and thus this release is maked as a developer release.

I'd be happy to share maintenance with someone that has time for this kind of project.

=head1 SUBROUTINES/METHODS

=cut

use App::Editor::GVip::View ;
use App::Editor::GVip::Menu ;
use Text::Editor::Vip::Buffer ;
use Text::Editor::Vip::Actions ;

#---------------------------------------------------------------------------------------------

sub new
{
my ($class, %arguments) = @_ ;

my ($window_width, $window_height) = (400, 600) ;

my $window = new Gtk2::Window() ;

$window->signal_connect(destroy => sub {Gtk2->main_quit});
$window->set_default_size($window_width, $window_height);
$window->set_position('none');

my $vbox = new Gtk2::VBox(FALSE, 0) ;
my ($menubar, $accelerator) = App::Editor::GVip::Menu::GetMenu($window) ;

$vbox->pack_start($menubar, FALSE, FALSE, 0) ;
#~ $window->add_accelerator_group($accelerator) ;

my $panel = new Gtk2::VPaned() ;

my $notebook = new Gtk2::Notebook() ;
$notebook->set_tab_pos('top') ;

# make notebook change the title when new one is selected
$notebook->signal_connect('switch-page' => sub{ $window->UpdateTitle(@_)}) ;

$panel->add1($notebook) ;

#~ my $terminal = Gtk2::DrawingArea->new() ;
#~ $panel->add2($terminal) ;
#~ $panel->set_position(1000) ;

$vbox->pack_start($panel, TRUE, TRUE, 0) ;

$window->add($vbox) ;

$window->{BUFFERS} = [] ;
$window->{NOTEBOOK} = $notebook ;
$window->{SETUP_DATA} = \%arguments ;

bless($window, ref($class) || $class) ;
}

#---------------------------------------------------------------------------------------------

sub UpdateTitle
{
my ($editor, $notebook, $time_maybe, $tab) = @_ ;

#~ print DumpTree(\@_, 'update title', MAX_DEPTH => 1)  ;

for my $view (@{$editor->{BUFFERS}})
	{
	if($view->{TAB} == $tab)
		{
		$editor->set_title($view->{FILE_NAME} || 'Untitled') ;
		last ;
		}
	}
}

#---------------------------------------------------------------------------------------------

use Gtk2::Gdk::Keysyms ;

# we know default uses 32 .. 255 (as character) but we need it to use gtk symboles
my %key_to_symbole = () ;
for my $key (keys %Gtk2::Gdk::Keysyms)
	{
	$key_to_symbole{$Gtk2::Gdk::Keysyms{$key}} = $key ;
	}
	
my %ascii_keys= () ;
for my $key (32 .. 255)
	{
	if(exists $key_to_symbole{$key})
		{
		my $chr_key = chr($key) ;
		
		$ascii_keys{$chr_key} = $key_to_symbole{$key} ;
		#~ print " $chr_key ($key) => $key_to_symbole{$key}\n" ;
		}
	}

#---------------------------------------------------------------------------------------------

sub AddView
{
my ($editor, $file_name) = @_ ;

my $tab_name = 'Untitled' ;

my ($volume, $directories, $file) ;
my ($basename, $path, $file_extension) ;

if(defined $file_name)
	{
	($volume, $directories, $file) = File::Spec->splitpath($file_name);
	($basename, $path, $file_extension) = File::Basename::fileparse($file, ('\..*')) ;
	
	$tab_name = $file ;
	}

my $new_buffer = GetNewBuffer($file_name) ;
$new_buffer->ExpandWith('PrintError', \&DisplayBufferErrorModal) ;

# find out what to load for this type of file

my $setup_path = $editor->{SETUP_DATA}{SETUP_PATH} ;

my $config = do "$setup_path/default_settings.pl" ;

$config->{setup_path} = $setup_path ;

my @action_files = @{$config->{DEFAULT_ACTIONS}} ;
push @action_files, $config->{$file_extension} if(defined $file_extension && exists $config->{$file_extension}) ;

# locate the files in the setup directory
@action_files = map {"$setup_path/$_"} @action_files ;

my $view = new App::Editor::GVip::View($new_buffer) ;
my $actions = $view->GetActions() ;

for my $action_file (@action_files)
	{
	eval { $actions->Load(\%ascii_keys, $view, $action_file) ;} ;
	DisplayMessageModal(new Gtk2::Window(), "Couldn't load actions! Errors: $@") if($@) ;
	}

eval <<'EOE' ;
	use lib $editor->{SETUP_DATA}{SETUP_PATH} ;  ;
	use Language::Perl::Perl ;
EOE

croak $@ if $@ ;

$view->{LEXER} = Lexer::Perl->new($setup_path) ;
#~ print DumpTree $view->{LEXER} ;

my $label = new Gtk2::Label($tab_name) ;

my $tab = $editor->{NOTEBOOK}->append_page($view->{WIDGET}, $label) ;
push @{$editor->{BUFFERS}},
	{
	BUFFER    => $new_buffer,
	FILE_NAME => $file_name,
	TAB       => $tab,
	};

$editor->show_all() ;

return($tab) ;
}

#---------------------------------------------------------------------------------------------

sub ShowTab
{
my ($editor, $tab_number) = @_ ;

$editor->{NOTEBOOK}->set_current_page($tab_number) ;
}

#---------------------------------------------------------------------------------------------

sub GetNewBuffer
{
my ($file_name) = @_ ;

my $buffer = Text::Editor::Vip::Buffer->new();
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::Display') ;
$buffer->LoadAndExpandWith('Text::Editor::Vip::Buffer::Plugins::File') ;

if(defined $file_name)
	{
	$buffer->InsertFile($file_name) ;
	}

$buffer->SetModificationPosition(0, 0) ;

return($buffer) ;
}

#------------------------------------------------------------------------------------------------------

sub DisplayMessageModal
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
$dialog->run() ;
}

#------------------------------------------------------------------------------------------------------

sub DisplayBufferErrorModal
{
my ($buffer, $message) = @_ ;

my $dialog = Gtk2::MessageDialog->new 
	(
	new Gtk2::Window(),
	'destroy-with-parent' ,
	'error' ,
	'close' ,
	$message ,
	) ;

$dialog->signal_connect(response => sub { $dialog->destroy ; 1 }) ;
$dialog->run() ;
}

#-------------------------------------------------------------------------------

sub A
{

=head2 A( xxx )

xxx description

  xxx some code

I<Arguments>

=over 2 

=item * $xxx - 

=back

I<Returns> - Nothing

I<Exceptions>

See C<xxx>.

=cut

my ($self) = @_ ;

if(defined $self && __PACKAGE__ eq ref $self)
	{
	# object sub
	my ($var, $var2) = @_ ;
	
	}
else	
	{
	# class sub
	unshift @_, $self ;
	}

return(0) ;
}

#-------------------------------------------------------------------------------

1 ;

=head1 BUGS AND LIMITATIONS

None so far.

=head1 AUTHOR

	Nadim ibn hamouda el Khemir
	CPAN ID: NH
	mailto: nadim@cpan.org

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Editor::GVip

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Editor-GVip>

=item * RT: CPAN's request tracker

Please report any bugs or feature requests to  L <bug-app-editor-gvip@rt.cpan.org>.

We will be notified, and then you'll automatically be notified of progress on
your bug as we make changes.

=item * Search CPAN

L<http://search.cpan.org/dist/App-Editor-GVip>

=back

=head1 SEE ALSO


=cut
