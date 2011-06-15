package UTM5::URFAClient;

use v5.10;
use strict;
use warnings;

=head1 NAME

UTM5::URFAClient - Perl wrapper for Netup URFA Client

=head1 VERSION
Version 0.1

=cut

our $VERSION = '0.1';

=head1 SYNOPSIS

	use UTM5::Client;
	my $client = new UTM5::URFAClient({
		host		=> 'netup.example.com',
		login		=> 'ssh_netup',
		exec		=> '/netup/utm5/bin/utm5_urfaclient',
		user		=> 'remote_user',
		password	=> 'remote_password'
	});
	print $client->whoami->{login};

=cut

use Net::SSH::Perl;
use XML::Twig;

=head1 SUBROUTINES/METHODS

=head2 new

Creates connection

	UTM5::URFAClient->new({<options>})

=head3 Options are:

=over

=item * host

	Remote host with Netup UTM5 with URFAClient module installed


=item * login

	Remote SSH user

=item * exec

	Path to the urfaclient binary

=item * user

	URFA client user

=item * password

	URFA client password

=back

=cut

sub new {
	my ($class, $self) = @_;

	bless $self, $class;

	#warn " * Initializing SSH connection to $self->{host}...";
	$self->{ssh} = Net::SSH::Perl->new($self->{host}, { debug => 1 });
	#warn "DONE\n";
	#warn " * Logging in, user: $self->{login}...";
	$self->{ssh}->login($self->{login}) || die "ssh: $!";
	#print "DONE\n";

	return $self;
}

=head2 ssh

	Returns current SSH connection

=cut

sub ssh {
	my $self = shift;

	return $self->{ssh} if $self->{ssh};
	die "Errors while connecting via SSH";
}

sub _parse_array {
	my ($data, $t, $array) = @_;
	my $name = $array->prev_sibling('integer')->att('name');
	$data->{$name} = [];

	foreach my $item ($array->children('item')) {
		my $item_data = {};

		foreach my $child ($item->children) {
			_parse_field($item_data, $child, 1);
		}

		push @{$data->{$name}}, $item_data;
	}
}

sub _parse_field {
	my ($data, $element, $isArray) = @_;

	if($element->parent->tag ne 'item' || $isArray) {
		$data->{$element->att('name')} = $element->att('value');
	}
}

sub _parse {
	my ($self, $data) = @_;
	my $result = {};

	my $t = XML::Twig->new(twig_handlers => {
		'integer'		=> sub { _parse_field($result, $_) },
		'long'			=> sub { _parse_field($result, $_) },
		'double'		=> sub { _parse_field($result, $_) },
		'string'		=> sub { _parse_field($result, $_) },
		'ip_address'	=> sub { _parse_field($result, $_) },
		'array'			=> sub { _parse_array($result, @_) },
	})->parse($data);

	return $result;
}

sub _exec {
	my ($self, $cmd, $params) = @_;
	my $param_string;

	if($params) {
		while(my ($key, $value) = each %$params) {
			$param_string .= " $key=$value";
		}
	}

	#print " * Executing SSH command: $cmd";
	my ($stdout, $stderr, $exit) = $self->ssh->cmd("$self->{exec} -l '$self->{user}' -P '$self->{password}' -a $cmd $param_string");
	#print "DONE\n\n";

	my $result = _parse($self, $stdout);

	return $result;
}

# = = = = = = = = = = = =   URFAClient Functions   = = = = = = = = = = = = #

=head2 whoami

	Returns current user info

=cut

sub whoami {
	my $self = shift;

	return $self->_exec('whoami');
}

=head1 AUTHOR

Nikita Melikhov, C<< <ver at 0xff.su> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-utm5-urfaclient at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=UTM5-URFAClient>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.



=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc UTM5::URFAClient


You can also look for information at:

=over 4

=item * Netup official site

L<http://www.netup.ru/>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=UTM5-URFAClient>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/UTM5-URFAClient>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/UTM5-URFAClient>

=item * Search CPAN

L<http://search.cpan.org/dist/UTM5-URFAClient/>

=back


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Nikita Melikhov.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of UTM5::URFAClient
