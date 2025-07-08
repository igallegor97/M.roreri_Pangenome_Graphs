import sys
import gzip

def determine_svtype(ref, alt):
    if ',' in alt:
        return "MULTIALLELIC"
    if len(ref) == 1 and len(alt) == 1:
        return "SNP"
    elif len(ref) > len(alt):
        return "DEL"
    elif len(ref) < len(alt):
        return "INS"
    elif len(ref) == len(alt) and ref != alt:
        return "INV"
    else:
        return "OTHER"

def open_vcf(path):
    return gzip.open(path, 'rt') if path.endswith('.gz') else open(path, 'r')

def annotate_vcf(input_path, output_path):
    with open_vcf(input_path) as infile, open(output_path, 'w') as outfile:
        for line in infile:
            if line.startswith("##"):
                outfile.write(line)
            elif line.startswith("#CHROM"):
                # Add new INFO field definition
                outfile.write("##INFO=<ID=SVTYPE,Number=1,Type=String,Description=\"Inferred structural variant type\">\n")
                outfile.write(line)
            else:
                parts = line.strip().split("\t")
                ref = parts[3]
                alt = parts[4]
                svtype = determine_svtype(ref, alt)
                # Append SVTYPE to INFO field
                if parts[7] == ".":
                    parts[7] = f"SVTYPE={svtype}"
                else:
                    parts[7] += f";SVTYPE={svtype}"
                outfile.write("\t".join(parts) + "\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python annotate_svtype.py input.vcf(.gz) output.vcf")
        sys.exit(1)

    annotate_vcf(sys.argv[1], sys.argv[2])
