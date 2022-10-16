package de.ozin;

import de.ozin.homebrew.Brew;

import java.io.IOException;
import java.util.List;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args ) throws Exception {
        new Brew().install("bash");
    }
}
