import java.io.*;
import java.util.Dictionary;
import java.util.Hashtable;

public class main {
    private static Dictionary<String, String> functions = new Hashtable<>();

    public static void main(String[] args) throws IOException {
        String input  = "input.txt";
        String output = "output.txt";

        File inputFile = new File(input);
        BufferedReader br = new BufferedReader(new FileReader(inputFile));
        PrintWriter writer = new PrintWriter(output, "UTF-8");
        setupDict();

        String assemblyCode;
        while ((assemblyCode = br.readLine()) != null) {
            // System.out.println("|" + assemblyCode + "|");
            if (assemblyCode.trim().equals("") || (assemblyCode.charAt(0) == '/' && assemblyCode.charAt(1) == '/')) {
                continue;
            }
            System.out.println(assemblyCode);
            String machineCode = "0" + compile(assemblyCode);
            System.out.println(machineCode);
            writer.println(machineCode);
        }
        br.close();
        writer.close();
    }

    private static void setupDict() {
        functions.put("copy",   "d0100"); // data
        functions.put("add",    "d0110");
        functions.put("neg",    "d0101");
        functions.put("sub",    "d0111");
        functions.put("nop",    "n0000"); // nop
        functions.put("setn",   "s0001"); // setn
        functions.put("loadr",  "m0011"); // memory
        functions.put("storer", "m0010");
        functions.put("jumpn",  "u1000"); // branch uncond
        functions.put("jumpr",  "r1110"); // branch to reg
        functions.put("jeqzn",  "b1ooo"); // branch
        functions.put("jnezn",  "b1001");
        functions.put("jgtzn",  "b1010");
        functions.put("jltzn",  "b1011");
    }

    private static String compile(String input) {
        String[] assembly = input.split(" ");
        for(int idx = 0; idx < assembly.length; idx++) {
            assembly[idx] = assembly[idx].trim().toLowerCase();
        }
        String funct = functions.get(assembly[0]);
        if (funct == null) {
            System.out.println("Function " + funct + " not found.");
            return "xxxx" + nop();
        }
        String functMC = funct.substring(1);
        switch (funct.charAt(0)) {
            case 'd':
                return functMC + dataProcessing(assembly);
            case 'n':
                return functMC + nop();
            case 's':
                return functMC + setn(assembly);
            case 'm':
                return functMC + memory(assembly);
            case 'u':
                return functMC + branchUncond(assembly);
            case 'r':
                return functMC + branchToReg(assembly);
            case 'b':
                return functMC + branch(assembly);
            default:
                System.out.println("Function evaluation error for " + funct);
                return "xxxx" + nop();
        }
    }

    private static String nop() {
        return "00000000000";
    }

    private static String parseReg(String assembly) {
        if(assembly.charAt(0) == 'r') {
            assembly = assembly.substring(1);
        }
        String mc = Integer.toBinaryString(Integer.valueOf(assembly));
        if (Integer.valueOf(assembly) > 7 || Integer.valueOf(assembly) < 0 || mc.length() > 3) {
            System.out.printf("Register number is outside of range 0-7:" + assembly);
            return "xxx";
        }
        while (mc.length() < 3) {
            mc = "0" + mc;
        }
        return mc;
    }

    private static String parseImm(String assembly) {
        String mc = Integer.toBinaryString(Integer.valueOf(assembly));
        if (mc.length() > 8) {
            System.out.println("Immediate value is outside of range 0 to 2^8-1 or -2^7 to -2^7-1:" + assembly);
            return "xxxxxxxx";
        }
        while (mc.length() < 8) {
            mc = "0" + mc;
        }
        return mc;
    }

    private static String dataProcessing(String[] assembly) {
        String rX = parseReg(assembly[1]);
        String rY = parseReg(assembly[2]);
        String rZ = "000";
        if(functions.get(assembly[0]).charAt(3) == '1') {
            // two registers
            rZ = parseReg(assembly[3]);
        }
        return rX + rY + rZ + "00";
    }

    private static String setn(String[] assembly) {
        String rX = parseReg(assembly[1]);
        String N  = parseImm(assembly[2]);
        return rX + N;
    }

    private static String memory(String[] assembly) {
        String rX = parseReg(assembly[1]);
        String rY = parseReg(assembly[2]);
        if (functions.get(assembly[0]).charAt(4) == '1') {
            // loadr
            return rX + "000" + rY + "00";
        } else {
            // storer
            return "000" + rX + rY + "00";
        }
    }

    private static String branchUncond(String[] assembly) {
        String N = parseImm(assembly[1]);
        return "000" + N;
    }
    private static String branchToReg(String[] assembly) {
        String rX = parseReg(assembly[1]);
        return rX + "00000000";
    }
    private static String branch(String[] assembly) {
        String rX = parseReg(assembly[1]);
        String N  = parseImm(assembly[2]);
        return rX + N;
    }
}
