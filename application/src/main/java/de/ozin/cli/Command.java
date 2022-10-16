package de.ozin.cli;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Arrays;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.function.Function;
import java.util.stream.Collectors;

public class Command {

    private static final ExecutorService executorService = Executors.newFixedThreadPool(5, r -> {
        final Thread t = new Thread(r);
        t.setDaemon(true);
        return t;
    });

    public static <T> T start(Function<BufferedReader, T> stdoutInterpreter, String... command) {
        ProcessBuilder pb = new ProcessBuilder(command);
        final Process process;
        try {
            System.out.println("Trying to execute: " + Arrays.toString(command));
            process = pb.start();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        final Future<T> stdout = getOutput(process.inputReader(), stdoutInterpreter);
        final Future<String> stderr = getOutput(
                process.errorReader(),
                br -> br.lines().collect(Collectors.joining("\n"))
        );

        try {
            stdout.get();
            stderr.get();

            if (process.exitValue() == 0)
                return stdout.get();

            throw new IllegalStateException(stderr.get());
        } catch (InterruptedException | ExecutionException e) {
            throw new RuntimeException(e);
        }
    }

    public static void start(String... command) {
        start(br -> null, command);
    }

    private static <T> Future<T> getOutput(BufferedReader bufferedReader, Function<BufferedReader, T> stdoutInterpreter) {
        return executorService.submit(() -> {
            try (bufferedReader) {
                return stdoutInterpreter.apply(bufferedReader);
            }
        });
    }
}
