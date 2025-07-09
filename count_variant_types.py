import argparse
import subprocess

def count_sv(vcf, svtype):
    cmd = ['bcftools', 'view', '-i', f'SVTYPE="{svtype}"', vcf]
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    count = sum(1 for _ in p.stdout)
    return count

def count_snps_indels(vcf, var_type):
    cmd = ['bcftools', 'view', '-v', var_type, vcf]
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    count = sum(1 for _ in p.stdout)
    return count

def main(vcf, out):
    with open(out, 'w') as f:
        f.write("Variant Type\tCount\n")
        for svtype in ['DEL', 'INS', 'INV']:
            c = count_sv(vcf, svtype)
            f.write(f"{svtype}\t{c}\n")
        snps = count_snps_indels(vcf, 'snps')
        indels = count_snps_indels(vcf, 'indels')
        f.write(f"SNPs\t{snps}\n")
        f.write(f"Indels\t{indels}\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--vcf', required=True)
    parser.add_argument('--out', required=True)
    args = parser.parse_args()
    main(args.vcf, args.out)
