using System;
using System.IO;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace TholinStuff {
	struct CodeLine {
		public CodeLine(string s, int u) {
			line = s;
			lineNum = u;
			nextAddress = -1;
		}
		public string line { get; }
		public int lineNum { get; }
		public int nextAddress { get; set; }
	}
	class Macro {
		private string instr;
		private string[] args;
		private string[] lines;
		
		public Macro(string def, string[] lines) {
			string[] parts = def.Split(new char[0], StringSplitOptions.RemoveEmptyEntries);
			if(parts.Length == 0 || parts.Length > 2 || parts[0].StartsWith("$")) throw new Exception($"Invalid macro definition: {def}");
			instr = parts[0];
			if(parts.Length == 1) args = null;
			else {
				args = parts[1].Split(",");
				for(int i = 0; i < args.Length; i++) {
					args[i] = args[i].Trim();
				}
			}
			foreach(string s in lines) {
				if(string.IsNullOrEmpty(s.Trim())) throw new Exception($"Empty line in macro definition: {def}");
			}
			this.lines = lines;
		}
		
		public bool Matches(string line) {
			if(string.IsNullOrEmpty(line.Trim())) return false;
			string[] parts = line.Split(new char[0], StringSplitOptions.RemoveEmptyEntries);
			if(!parts[0].Equals(instr)) return false;
			if(parts.Length == 1) {
				return args == null;
			}else {
				if(args == null) return false;
				string[] largs = parts[1].Split(",");
				if(largs.Length != args.Length) return false;
				for(int i = 0; i < args.Length; i++) {
					if(args[i].StartsWith("$")) continue;
					if(args[i].Equals("[inreg]")) {
						if(string.Equals("[inreg]", largs[i], StringComparison.OrdinalIgnoreCase)) return true; //For internal use only, so macro length calculations can proceed normaly
						if(!string.Equals("dia", largs[i], StringComparison.OrdinalIgnoreCase) && !string.Equals("dib", largs[i], StringComparison.OrdinalIgnoreCase) && !string.Equals("3", largs[i]) && !string.Equals("4", largs[i])) return false;
						else return true;
					}
					if(!string.Equals(args[i], largs[i], StringComparison.OrdinalIgnoreCase)) return false;
				}
				return true;
			}
		}
		
		public string[] Resolve(string[] sargs, int nextAddress) {
			if(args != null && sargs.Length != args.Length) return null;
			if(args == null && sargs.Length != 0) return null;
			Dictionary<string, string> dargs = new Dictionary<string, string>();
			if(args != null) for(int i = 0; i < args.Length; i++) {
				string key = args[i];
				if(key.StartsWith("$")) key = key.Substring(1);
				dargs.Add(key, sargs[i]);
			}
			
			string[] res = new string[lines.Length];
			for(int i = 0; i < lines.Length; i++) {
				string line = lines[i];
				string[] parts = line.Split(new char[0], StringSplitOptions.RemoveEmptyEntries);
				res[i] = parts[0];
				if(parts.Length != 1) {
					parts = parts[1].Split(",");
					for(int j = 0; j < parts.Length; j++) {
						string part = parts[j];
						if(part.StartsWith("$")) {
							string key = part.Substring(1);
							if(key.Contains('.')) {
								string[] keyParts = key.Split('.');
								if(keyParts.Length != 2) return null;
								if(!dargs.ContainsKey(keyParts[0])) return null;
								uint val = uint.Parse(dargs[keyParts[0]]);
								uint bit;
								bool inv = keyParts[1].EndsWith("!");
								if(inv) keyParts[1] = keyParts[1].Substring(0, keyParts[1].Length - 1);
								if(!uint.TryParse(keyParts[1], out bit)) return null;
								val >>= (int)bit;
								val &= 1;
								if(inv) val ^= 1;
								part = val.ToString();
							}else {
								if(!dargs.ContainsKey(key)) return null;
								part = dargs[key];
							}
						} else if(part.Equals("[inreg]")) {
							string reg = dargs[part];
							if(string.Equals("dia", reg, StringComparison.OrdinalIgnoreCase) || string.Equals("3", reg)) part = "3";
							else if(string.Equals("dib", reg, StringComparison.OrdinalIgnoreCase) || string.Equals("4", reg)) part = "4";
							else return null;
						} else if(part.StartsWith("[next]")) {
							if(nextAddress == -1) {
								Console.WriteLine("Unexpected error resolving [next]! This shouldn’t be happening, please report a bug!");
								return null;
							}
							if(part.Contains('.')) {
								int a = nextAddress;
								string[] keyParts = part.Split('.');
								if(keyParts.Length != 2) return null;
								uint bit;
								if(!uint.TryParse(keyParts[1], out bit)) return null;
								a >>= (int)bit;
								a &= 1;
								part = a.ToString();
							}else part = nextAddress.ToString();
						}
						if(j == 0) res[i] += " ";
						res[i] += part;
						if(j != parts.Length - 1) res[i] += ",";
					}	
				}
			}
			return res;
		}
		
		public int GetLength() {
			return lines.Length;
		}
		
		public string[] GetLines() {
			return this.lines;
		}
	}
	class MC14500ASM {
        private static string[] invalidLabelStarts = {"0","1","2","3","4","5","6","7","8","9",".","$"};
        private static char[] invalidLabelSymbols = {'-', '+', '*', '/', '>', '<', ',', '\\', '\'', '%', '.', '$'};
        
        private static string[] reservedSymbols = {"mar", "rr", "dob", "dr", "dia", "dib", "zf", "cf"};
		
		private List<Macro> macros = new List<Macro>();
		
		public MC14500ASM() {
			string[] lines = File.ReadAllLines("macros.txt");
			bool inMacro = false;
			string macroDef = "$";
			List<string> macroLines = new List<string>();
			for(int i = 0; i < lines.Length + 1; i++) {
				string line = i == lines.Length ? "" : lines[i];
				if(!line.StartsWith("\t")) {
					if(inMacro) {
						string[] macroLinesArr = new string[macroLines.Count];
						for(int j = 0; j < macroLines.Count; j++) macroLinesArr[j] = macroLines[j];
						macroLines.Clear();
						macros.Add(new Macro(macroDef, macroLinesArr));
						inMacro = false;
					}else if(!string.IsNullOrEmpty(line.Trim())) {
						macroDef = line;
						inMacro = true;
					}
				}else {
					if(inMacro) macroLines.Add(line.Trim());
				}
			}
		}
		
		private static bool ParseNum(string s, out uint res) {
			uint temp;
			if(s.StartsWith("0b")) {
				s = s.Substring(2);
				temp = 0;
				for(int i = 0; i < s.Length; i++) {
					temp <<= 1;
					char c = s[i];
					if(c == '1') temp += 1;
					else if(c != '0') {
						res = 0;
						return false;
					}
				}
				res = temp;
				return true;
			}else if(s.StartsWith("0x")) {
				s = s.Substring(2);
				bool a = uint.TryParse(s, System.Globalization.NumberStyles.HexNumber, null, out temp);
				if(!a) res = 0;
				else res = temp;
				return a;
			}else if(s.StartsWith('\'')) {
				if(s.Length != 3 || s[2] != '\'') {
					res = 0;
					return false;
				}
				res = s[1];
				return true;
			}else {
				bool a = uint.TryParse(s, System.Globalization.NumberStyles.None, null, out temp);
				if(!a) res = 0;
				else res = temp;
				return a;
			}
		}
		
		//Might makes this more complex in the future
		private static bool ParseInstrArg(string s, Dictionary<string, uint> symbolTable, out uint res) {
			uint a;
			if(ParseNum(s, out a)) {
				res = a;
				return true;
			}
			if(symbolTable.ContainsKey(s)) {
				res = symbolTable[s];
				return true;
			}
			res = 0;
			return false;
		}
		
		private static bool IsReservedSymbol(string s) {
			foreach(string sym in reservedSymbols) {
				if(string.Equals(sym, s, StringComparison.OrdinalIgnoreCase)) return true;
			}
			return false;
		}
		
		private uint GetMacroLengthRecursive(Macro m) {
			uint count = 0;
			foreach(string s in m.GetLines()) {
				bool hasMatch = false;
				foreach(Macro m2 in macros) {
					if(m2.Matches(s)) {
						hasMatch = true;
						count += GetMacroLengthRecursive(m2);
						break;
					}
				}
				if(!hasMatch) count++;
			}
			return count;
		}
		
		public void Assemble(string source) {
			string[] linesIn = File.ReadAllLines(source);
			//Remove comments
			for(int i = 0; i < linesIn.Length; i++) {
				if(linesIn[i].IndexOf(';') >= 0) linesIn[i] = linesIn[i].Substring(0, linesIn[i].IndexOf(';'));
				linesIn[i] = linesIn[i].TrimEnd();
				linesIn[i] = Regex.Replace(linesIn[i], @"\s+", " ");
			}
			List<CodeLine> lines = new List<CodeLine>();
			Dictionary<string, uint> symbolTable = new Dictionary<string, uint>();
			symbolTable.Add("dob", 2);
			symbolTable.Add("dia", 3);
			symbolTable.Add("dib", 4);
			symbolTable.Add("mar", 1);
			symbolTable.Add("dr", 0);
			symbolTable.Add("zf", 8);
			symbolTable.Add("cf", 9);
			Console.WriteLine("Pass 1");
			uint ptr = 0;
			for(int i = 0; i < linesIn.Length; i++) {
				string line = linesIn[i];
				if(string.IsNullOrEmpty(line)) continue;
				if(line.ToLower().Trim().Equals("end")) break;
				if(line.StartsWith('\t') || line.StartsWith(' ')) {
					//Instruction
					line = line.TrimStart();
					line = line.ToLower();
					CodeLine cl = new CodeLine(line, i + 1);
					if(lines.Count != 0) {
						CodeLine prev = lines[lines.Count - 1];
						prev.nextAddress = (int)ptr;
						lines[lines.Count - 1] = prev;
					}
					lines.Add(cl);
					bool hasMatch = false;
					foreach(Macro m in macros) {
						if(m.Matches(line)) {
							hasMatch = true;
							ptr += GetMacroLengthRecursive(m);
							break;
						}
					}
					if(!hasMatch) ptr++;
				}else {
					line = line.ToLower();
					//Label or equ
					string name;
					uint val;
					if(line.IndexOf(' ') > 0) {
						string[] s = line.Split(new char[0], StringSplitOptions.RemoveEmptyEntries);
						if(s.Length != 3 || !(s[1].Equals("equ"))) {
							Console.WriteLine($"Error on line {i + 1}: Not an instruction, label or symbol definition.");
							return;
						}
						name = s[0];
						if(!ParseInstrArg(s[2], symbolTable, out val)) {
							Console.WriteLine($"Error on line {i + 1}: Parse error on symbol value: not a number.");
							return;
						}
					}else if(line.EndsWith(':')) {
						line = line.Substring(0, line.Length - 1);
						if(line.Contains(' ') || line.Contains('\t') || line.Length == 0) {
							Console.WriteLine($"Error on line {i + 1}: Label name cannot contain spaces or be empty.");
							return;
						}
						name = line;
						val = ptr;
					}else {
						Console.WriteLine($"Error on line {i + 1}: Not an instruction, label or symbol definition.");
						return;
					}
					foreach(char c in invalidLabelSymbols) {
						if(name.Contains(c)) {
							Console.WriteLine($"Error on line {i + 1}: Forbidden character '{c}' in label/symbol name.");
							return;
						}
					}
					foreach(string s in invalidLabelStarts) {
						if(name.StartsWith(s)) {
							Console.WriteLine($"Error on line {i + 1}: Forbidden label/symbol name.");
							return;
						}
					}
					if(IsReservedSymbol(name)) {
							Console.WriteLine($"Error on line {i + 1}: Reserved label/symbol name.");
							return;
					}
					if(symbolTable.ContainsKey(name)) {
						Console.WriteLine($"Error on line {i + 1}: Redefinition of symbol {name}");
						return;
					}
					symbolTable.Add(name, val);
				}
			}
			
			Console.WriteLine("Pass 2");
			bool hadMacros = true;
			while(hadMacros) {
				hadMacros = false;
				for(int i = 0; i < lines.Count; i++) {
					string line = lines[i].line;
					bool hasMatch = false;
					foreach(Macro m in macros) {
						if(m.Matches(line)) {
							hasMatch = true;
							string[] parts = line.Split(new char[0], StringSplitOptions.RemoveEmptyEntries);
							string[] res = null;
							if(parts.Length == 2) {
								parts = parts[1].Split(",");
								string[] sargs = new string[parts.Length];
								for(int j = 0; j < sargs.Length; j++) {
									if(IsReservedSymbol(parts[j])) sargs[j] = parts[j];
									else {
										uint ival;
										if(!ParseInstrArg(parts[j], symbolTable, out ival)) {
											Console.WriteLine($"Error on line {lines[i].lineNum}: Invalid expression \"{parts[j]}\".");
											return;
										}
										sargs[j] = ival.ToString();
									}
								}
								res = m.Resolve(sargs, lines[i].nextAddress);
							}else {
								res = m.Resolve(new string[0], lines[i].nextAddress);
							}
							if(res == null) {
								Console.WriteLine($"Error on line {lines[i].lineNum}: Error expanding macro.");
								return;
							}
							for(int j = 0; j < res.Length; j++) {
								CodeLine l = new CodeLine(res[j], lines[i].lineNum);
								if(j == 0) lines[i] = l;
								else {
									i++;
									lines.Insert(i, l);
								}
							}
							break;
						}
					}
					if(hasMatch) {
						hadMacros = true;
						continue;
					}
					lines[i] = new CodeLine(line, lines[i].lineNum);
				}
			}
			
			Console.WriteLine("Pass 3");
			//Parse built-in macro instructions
			for(int i = 0; i < lines.Count; i++) {
				string line = lines[i].line;
				if(string.IsNullOrEmpty(line)) continue;
				string[] parts = line.Split(new char[0], StringSplitOptions.RemoveEmptyEntries);
				if(parts[0].Equals("ldi") && parts.Length == 2) {
					parts = parts[1].Split(",");
					if(string.Equals(parts[0], "rr", StringComparison.OrdinalIgnoreCase)) {
						if(parts.Length != 2) {
							Console.WriteLine($"Error on line {lines[i].lineNum}: Expected exactly one argument to instruction");
							return;
						}
						uint val;
						if(!ParseInstrArg(parts[1], symbolTable, out val)) {
							Console.WriteLine($"Error on line {lines[i].lineNum}: Invalid expression \"{parts[1]}\".");
							return;
						}
						if(val == 0) line = "ldc 0";
						else if(val == 1) line = "ld 0";
						else {
							Console.WriteLine($"Error on line {lines[i].lineNum}: Instruction argument does not resolve to 0 or 1.");
							return;
						}
					}
				}else if(parts[0].Equals("sti")) {
					if(parts.Length != 2) {
						Console.WriteLine($"Error on line {lines[i].lineNum}: Expected exactly two arguments to instruction 'sti'");
						return;
					}
					parts = parts[1].Split(",");
					uint val;
					if(!ParseInstrArg(parts[0], symbolTable, out val)) {
						Console.WriteLine($"Error on line {lines[i].lineNum}: Invalid expression \"{parts[0]}\".");
						return;
					}
					if(val == 0) line = $"stoc {parts[1]}";
					else if(val == 1) line = $"sto {parts[1]}";
					else {
						Console.WriteLine($"Error on line {lines[i].lineNum}: First instruction argument does not resolve to 0 or 1.");
						return;
					}
				}
				lines[i] = new CodeLine(line, lines[i].lineNum);
			}
			
			string outputFilenamePre = "";
			string[] partsf = source.Split('.');
			for(int i = 0; i < partsf.Length - 1; i++) {
				outputFilenamePre = $"{outputFilenamePre}{(i == 0 ? "" : ".")}{partsf[i]}";
			}
			
			Console.WriteLine("Pass 4");
			//Actually assemble the code
			StreamWriter sw = new StreamWriter($"{outputFilenamePre}.lst");
			foreach(KeyValuePair<string, uint> entry in symbolTable) {
				sw.WriteLine($"equ\t{entry.Key}\t\t{entry.Value}\t\t0x{entry.Value.ToString("X4")}");
			}
			sw.WriteLine(" ");
			sw.Flush();
			
			uint[] outputData = new uint[65535];
			ptr = 0;
			for(int i = 0; i < lines.Count; i++) {
				string line = lines[i].line;
				uint instr = 0;
				uint arg = 0;
				string[] parts = line.Split(new char[0], StringSplitOptions.RemoveEmptyEntries);
				if(parts.Length > 2) {
					Console.WriteLine($"Error on line {lines[i].lineNum}: Expected no more than two arguments to instruction");
					return;
				}
				if(parts.Length == 2) {
					if(!ParseInstrArg(parts[1], symbolTable, out arg)) {
						Console.WriteLine($"Error on line {lines[i].lineNum}: Invalid expression \"{parts[1]}\".");
						return;
					}
					if(arg > 15) {
						Console.WriteLine($"Error on line {lines[i].lineNum}: Value overflow in expression \"{parts[1]}\" ({arg}).");
						return;
					}
				}
				if(parts[0].Equals("nopo")) instr = 0;
				else if(parts[0].Equals("ld")) instr = 1;
				else if(parts[0].Equals("ldc")) instr = 2;
				else if(parts[0].Equals("and")) instr = 3;
				else if(parts[0].Equals("andc")) instr = 4;
				else if(parts[0].Equals("or")) instr = 5;
				else if(parts[0].Equals("orc")) instr = 6;
				else if(parts[0].Equals("xnor")) instr = 7;
				else if(parts[0].Equals("sto")) instr = 8;
				else if(parts[0].Equals("stoc")) instr = 9;
				else if(parts[0].Equals("ien")) instr = 10;
				else if(parts[0].Equals("oen")) instr = 11;
				else if(parts[0].Equals("jmp")) instr = 12;
				else if(parts[0].Equals("rtn")) instr = 13;
				else if(parts[0].Equals("skz")) instr = 14;
				else if(parts[0].Equals("nopf")) instr = 15;
				else {
					Console.WriteLine($"Error on line {lines[i].lineNum}: Invalid instruction \"{parts[0]}\".");
					return;
				}
				
				outputData[ptr] = (arg << 4) | instr;
				ptr++;
				if(ptr > 65535) {
					Console.WriteLine($"Error on line {lines[i].lineNum}: Out of space!");
					return;
				}
				
				sw.Write($"{outputData[ptr-1].ToString("X2")}\t\t{parts[0]}");
				if(parts.Length == 2) {
					sw.WriteLine($"\t{arg}");
				}else sw.WriteLine();
			}
			sw.Close();

			string outputFilename = $"{outputFilenamePre}.bin";
			byte[] outputDataBytes = new byte[ptr];
			for(int i = 0; i < ptr; i++) {
				outputDataBytes[i] = (byte)outputData[i];
			}
			File.WriteAllBytes(outputFilename, outputDataBytes);
			
			sw = new StreamWriter($"{outputFilenamePre}.txt");
			for(int i = 0; i < ptr; i++) {
				sw.WriteLine(outputDataBytes[i].ToString("X2"));
			}
			sw.WriteLine(" ");
			sw.Flush();
			sw.Close();
		}
		
		static void Main(string[] args) {
			if(args.Length < 1) {
				Console.WriteLine("Error: Must specify an input file");
				Environment.Exit(1);
				return;
			}
			MC14500ASM asm = new MC14500ASM();
			asm.Assemble(args[0]);
		}
	}
}
