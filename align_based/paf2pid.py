#!/usr/bin/env python3
import sys

def parse_paf_and_summarize_identity(paf_path):
    """
    Parses a PAF file and summarizes percent identity for each alignment block.

    :param paf_path: Path to the PAF file
    :return: List of tuples containing (query_name, target_name, percent_identity)
    """
    identities = []

    with open(paf_path, 'r') as file:
        for line in file:
            fields = line.strip().split('\t')
            if len(fields) < 12:
                continue  # skip malformed lines

            query_name = fields[0]
            target_name = fields[5]
            alignment_block_length = int(fields[10])  # Number of residue matches

            # Parse optional fields
            nm = None
            for field in fields[12:]:
                if field.startswith("NM:i:"):
                    nm = int(field[5:])
                    break

            if nm is not None and alignment_block_length > 0:
                # Matches = alignment block length - mismatches
                matches = alignment_block_length - nm
                percent_identity = (matches / alignment_block_length) * 100
                identities.append((query_name, target_name, percent_identity))
            else:
                identities.append((query_name, target_name, None))  # Cannot calculate

    return identities

def main():
    paf_file = sys.argv[1]
    identities = parse_paf_and_summarize_identity(paf_file)

    print(f"{'Query':<20} {'Target':<20} {'% Identity':>10}")
    print("-" * 55)
    for query, target, pid in identities:
        pid_str = f"{pid:.2f}" if pid is not None else "N/A"
        print(f"{query:<20} {target:<20} {pid_str:>10}")

if __name__ == "__main__":
    main()
