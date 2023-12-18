import java.io.*;

public class ToVerilogHex {
	public static int reverse(int b) {
	   b = (b & 0xF0) >> 4 | (b & 0x0F) << 4;
	   b = (b & 0xCC) >> 2 | (b & 0x33) << 2;
	   b = (b & 0xAA) >> 1 | (b & 0x55) << 1;
	   return b;
	}
	public static void main(String[] args) {
		try {
			if(args.length < 2) {
				System.out.println("ToVerilogHex [infile] [outfile]");
				System.exit(1);
			}
			int[] image = new int[16384];
			FileInputStream fis = new FileInputStream(new File(args[0]));
			BufferedWriter bw = new BufferedWriter(new FileWriter(new File(args[1])));
			FileOutputStream fos = new FileOutputStream(new File(args[1] + ".bin"));
			int ptr = 0;
			while(fis.available() > 0) {
				int ptrInv = ((ptr & 1) << 12) | ((ptr & 2) << 10) | ((ptr & 4) << 8) | ((ptr & 8) << 6) | ((ptr & 16) << 4) | ((ptr & 32) << 2) | ((ptr & 64) << 0) | ((ptr & 128) >> 2) | ((ptr & 256) >> 4) | ((ptr & 512) >> 6) | ((ptr & 1024) >> 8) | ((ptr & 2048) >> 10) | ((ptr & 4096) >> 12);
				int val1 = reverse(fis.read());
				int val2 = reverse(fis.read());
				image[ptrInv*2] = val2;
				image[ptrInv*2+1] = val1;
				ptr++;
			}
			for(int i = 0; i < image.length; i++) {
				bw.write(String.format("%02x", image[i]));
				bw.newLine();
				fos.write(image[i]);
			}
			fos.close();
			fis.close();
			bw.close();
		}catch(Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
}
