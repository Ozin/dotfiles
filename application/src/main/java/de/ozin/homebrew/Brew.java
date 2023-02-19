package de.ozin.homebrew;

import de.ozin.cli.Command;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Stream;

import static java.util.function.Predicate.not;

public class Brew {
    private final static Logger logger = LoggerFactory.getLogger(Brew.class);

    public List<String> list() {
        List<String> installedPackages = new ArrayList<>();
        Command.start(installedPackages::add, "brew", "list");
        return installedPackages;
    }

    public void install(String... packages) {
        if (Arrays.stream(packages).anyMatch(s -> s.contains(" "))) {
            throw new IllegalArgumentException("packages are not allowed to have spaces");
        }

        final Stream<String> uninstalledPackages = Arrays.stream(packages)
                                                         .filter(not(list()::contains));

        final String[] command = Stream.concat(Stream.of("brew", "install"), uninstalledPackages)
                                       .toArray(String[]::new);

        if (command.length == 2) {
            logger.info("No packages have to be installed");
            return;
        }

        Command.start(command);
    }

}
