# Digital Forensics: Steganography, File Deletion, and Recovery

Author: Gresa Hisa

---

## Overview

End-to-end digital forensics investigation demonstrating steganographic data embedding, evidence destruction simulation, forensic disk imaging, and recovery analysis. The workflow mirrors real-world DFIR scenarios involving covert communication channels and intentionally destroyed evidence.

---

## Environment

| Item | Detail |
|---|---|
| OS | Windows 11 |
| Steganography tool | steghide 0.5.1 (Windows binary) |
| Forensic imaging tool | FTK Imager 8.2.0.26 |
| Virtual disk | VHDX, NTFS, 2GB, mounted at D:\Stegdisk |

---

## Objectives

- Embed hidden text inside a JPEG using steganography
- Store the file on a virtual NTFS disk
- Delete the file to simulate evidence destruction
- Acquire forensic images before and after deletion
- Analyze images in FTK Imager
- Attempt recovery and document outcome

---

## 1. Steganographic Embedding

### Prepare files

- Carrier image: `Secret.jpg`
- Hidden message: `message.txt`

### Embed hidden message

```bash
steghide embed -cf Secret.jpg -ef message.txt -p YourPasswordHere
```

| Flag | Meaning |
|---|---|
| -cf | Cover file (carrier image) |
| -ef | Embedded file (secret text) |
| -p | Passphrase |

steghide compresses and encrypts the payload before embedding using LSB technique.

**Result:** A visually identical `Secret.jpg` containing hidden data.

### Extract hidden message

```bash
steghide extract -sf Secret.jpg -p YourPasswordHere
```

---

## 2. Evidence Destruction Simulation

- Copied stego JPEG to virtual disk: `D:\Secret.jpg`
- Acquired forensic image before deletion: `Stegdisk_before_delete_NEW.E01`
- Deleted the file inside the VHDX
- NTFS did not send the file to `$Recycle.Bin` — behaved as permanent delete (normal for small/removable NTFS volumes)
- Acquired forensic image after deletion: `Stegdisk_after_delete_NEW.E01`

---

## 3. Forensic Imaging

Acquired using FTK Imager:

```
File → Create Disk Image → Logical Drive → D:
Image type: E01 (EnCase)
```

MD5 and SHA1 hashes verified — no imaging errors. Proper forensic acquisition confirmed.

---

## 4. Forensic Analysis and Recovery

### Evidence tree (after-deletion image)

```
Stegdisk_after_delete_NEW.E01
    └── Stegdisk [NTFS]
        ├── $RECYCLE.BIN
        ├── [root]
        ├── [orphan]
        └── [unallocated space]
```

### Findings

| Location | Result |
|---|---|
| $RECYCLE.BIN | Empty |
| [root] | No file entries |
| [orphan] | No deleted entries |
| [unallocated space] | Zeroed clusters |
| JPEG signature (FF D8 FF) | Not found in raw sectors |

### Interpretation

On small NTFS volumes (VHDX, USB drives):

- Windows often performs immediate permanent deletion
- NTFS may overwrite MFT entries instantly
- No orphaned file metadata is retained
- No $R or $I recycle entries appear

---

## 5. Key Findings

- Deleted JPG was **not recoverable** — NTFS did not preserve deletion metadata and clusters were overwritten
- Steganographic payload survived as long as the file existed
- Windows Recycle Bin deletion is insufficient for secure erasure on standard volumes
- Small NTFS volumes behave differently from large drives — recovery is not guaranteed
- Forensic imaging before and after deletion provides evidentiary integrity regardless of recovery outcome

---

## 6. Recommendations

- Use secure wiping tools (e.g. Eraser, sdelete) for sensitive file removal
- Monitor for unusual JPG modifications in high-risk environments
- Restrict unauthorized use of steganographic applications
- Enable endpoint monitoring for file deletion events
- Perform regular forensic readiness assessments

---

## Conclusion

The stego image was successfully created with embedded hidden text and placed on a controlled NTFS virtual disk. After deletion, forensic analysis confirmed the file was not recoverable using standard techniques. This is a realistic DFIR outcome — deleted files are not always recoverable, particularly on small NTFS volumes or virtual disks. The investigation successfully demonstrates the full forensic chain from embedding to recovery attempt.
