package de.ozin.cli;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Arrays;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.function.Consumer;

import static java.util.Objects.requireNonNull;

public class Command {
    private final static Logger logger = LoggerFactory.getLogger(Command.class);

    private static final ExecutorService executorService = Executors.newFixedThreadPool(5, r -> {
        final Thread t = new Thread(r);
        t.setDaemon(true);
        return t;
    });

    public static void start(Consumer<String> stdoutInterpreter, String... command) {
        ProcessBuilder pb = new ProcessBuilder(command);
        final Process process;
        try {
            logger.debug("Trying to execute: {}", Arrays.toString(command));
            process = pb.start();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        final Future<Void> stdOut = getOutput(process.inputReader(), stdoutInterpreter);
        StringBuilder stdErrOutput = new StringBuilder();
        final Future<Void> stdErr = getOutput(process.errorReader(), stdErrOutput::append);

        try {
            stdOut.get();
            stdErr.get();

            if (process.exitValue() == 0) return;

            throw new IllegalStateException(stdErrOutput.toString());
        } catch (InterruptedException | ExecutionException e) {
            throw new RuntimeException(e);
        }
    }

    public static void start(String... command) {
        start(s -> {
        }, command);
    }

    private static Future<Void> getOutput(BufferedReader bufferedReader, Consumer<String> stdoutInterpreter) {
        return executorService.submit(() -> {
            try (bufferedReader) {
                bufferedReader.lines().forEach(stdoutInterpreter);
                //Thread.sleep(10_000);
                return null;
            }
        });
    }

    public static boolean exists(String command) {
        requireNonNull(command);

        if (!command.matches("[a-z]+")) {
            throw new IllegalArgumentException("Command seems to be malformed: " + command);
        }

        try {
            start("command", "-v", command);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
