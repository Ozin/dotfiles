package de.ozin.homebrew;

import de.ozin.cli.Command;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static java.util.function.Predicate.not;

public class Brew {

    public List<String> list() {
        return Command.start(br -> br.lines().collect(Collectors.toList()), "brew", "list");
    }

    public void install(String... packages) {
        final Stream<String> uninstalledPackages = Arrays.stream(packages)
                                                         .filter(not(list()::contains));

        final String[] command = Stream.concat(Stream.of("brew", "install"), uninstalledPackages)
                                       .toArray(String[]::new);

        if(command.length == 2) {
            System.out.println("No packages have to be installed");
            return;
        }

        Command.start(command);
    }

}
