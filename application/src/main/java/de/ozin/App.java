package de.ozin;

import de.ozin.cli.Command;
import de.ozin.homebrew.Brew;

public class App {
    public static void main(String[] args) throws Exception {
        System.out.print("Assuring brew is installed... ");
        if (Command.exists("brew")) {
            System.out.println("yes");
        } else {
            System.out.println("no");
            Command.start(s -> {},"curl", "-fsSL", "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh");
        }
        new Brew().install("bash");
    }
}
