use strict;
use warnings;

use File::chdir;

my @input = (
	['01_literal', qq(literal)],
	['02_double_quoted', qq("dquoted")],
	['03_single_quoted', qq('squoted')],
	['04_space_list_quoted', qq("alpha" 'beta')],
	['05_comma_list_quoted', qq("alpha", 'beta')],
	['06_space_list_complex', qq(gamme "'"delta"'")],
	['07_comma_list_complex', qq(gamma, "'"delta"'")],
	['08_escaped_backslash', qq(\\\\)],
);

my @template;

push @template, "01_inline";
push @template, << "EOF";
.result {
  output: %%;
  output: #{%%};
  output: "[#{%%}]";
  output: "#{%%}";
  output: '#{%%}';
  output: "['#{%%}']";
}
EOF


push @template, "02_variable";
push @template, << "EOF";
\$input: %%;
.result {
  output: \$input;
  output: #{\$input};
  output: "[#{\$input}]";
  output: "#{\$input}";
  output: '#{\$input}';
  output: "['#{\$input}']";
}
EOF

push @template, "03_inline_double";
push @template, << "EOF";
.result {
  output: #{#{%%}};
  output: #{"[#{%%}]"};
  output: #{"#{%%}"};
  output: #{'#{%%}'};
  output: #{"['#{%%}']"};
}
EOF

push @template, "04_variable_double";
push @template, << "EOF";
\$input: %%;
.result {
  output: #{#{\$input}};
  output: #{"[#{\$input}]"};
  output: #{"#{\$input}"};
  output: #{'#{\$input}'};
  output: #{"['#{\$input}']"};
}
EOF

push @template, "05_variable_quoted_double";
push @template, << "EOF";
\$input: %%;
.result {
  dquoted: "#{#{\$input}}";
  dquoted: "#{"[#{\$input}]"}";
  dquoted: "#{"#{\$input}"}";
  dquoted: "#{'#{\$input}'}";
  dquoted: "#{"['#{\$input}']"}";
  squoted: '#{#{\$input}}';
  squoted: '#{"[#{\$input}]"}';
  squoted: '#{"#{\$input}"}';
  squoted: '#{'#{\$input}'}';
  squoted: '#{"['#{\$input}']"}';
EOF
# ruby sass cannot handle these cases ...
pop(@template); pop(@template);


sub render {
	use File::Slurp qw(write_file);
	my ($names, $template, $input) = @_;
	$template =~ s/\%\%/$input/g;
	local $CWD = $CWD;
	foreach (@{$names}) {
		mkdir $_;
		$CWD = $_;
	}
	print "created ", join("/", @{$names}), "\n";
	return write_file('input.scss', { binmode => ':raw' }, $template);

}

while (defined(my $name = shift @template)) {
	my $template = shift(@template);
	foreach my $input (@input) {
		render([$input->[0], $name], $template, $input->[1]);
	}
}

<>;