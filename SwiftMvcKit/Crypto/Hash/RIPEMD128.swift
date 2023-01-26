//
//  RIPEMD.swift
//  HDWalletKit
//
//  Created by linke50 on 8/21/20.
//  Copyright © 2020 Essentia. All rights reserved.
//

import Foundation

struct RIPEMD128 {
    
    private var MDbuf: (UInt32, UInt32, UInt32, UInt32)
    private var buffer: Data
    private var count: Int64 // Total # of bytes processed.
    
    private init() {
        MDbuf = (0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476)
        buffer = Data()
        count = 0
    }
    
    private mutating func compress(_ X: UnsafePointer<UInt32>) {
        
        /* ROL(x, n) cyclically rotates x over n bits to the left */
        /* x must be of an unsigned 32 bits type and 0 <= n < 32. */
        func ROL(_ x: UInt32, _ n: UInt32) -> UInt32 {
            return (x << n) | ( x >> (32 - n))
        }
        
        /* the five basic functions F(), G() and H() */
        
        func F(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            return x ^ y ^ z
        }
        
        func G(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            return (x & y) | (~x & z)
        }
        
        func H(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            return (x | ~y) ^ z
        }
        
        func I(_ x: UInt32, _ y: UInt32, _ z: UInt32) -> UInt32 {
            return (x & z) | (y & ~z)
        }
        
        /* the ten basic operations FF() through III() */
        
        func FF(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ F(b, c, d) &+ x
            a = ROL(a, s)
        }
        
        func GG(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ G(b, c, d) &+ x &+ 0x5a827999
            a = ROL(a, s)
        }
        
        func HH(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ H(b, c, d) &+ x &+ 0x6ed9eba1
            a = ROL(a, s)
        }
        
        func II(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ I(b, c, d) &+ x &+ 0x8f1bbcdc
            a = ROL(a, s)
        }
        
        func FFF(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ F(b, c, d) &+ x &+ 0x00000000
            a = ROL(a, s)
        }
        
        func GGG(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ G(b, c, d) &+ x &+ 0x6d703ef3
            a = ROL(a, s)
        }
        
        func HHH(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ H(b, c, d) &+ x &+ 0x5c4dd124
            a = ROL(a, s)
        }
        
        func III(_ a: inout UInt32, _ b: UInt32, _ c: inout UInt32, _ d: UInt32, _ x: UInt32, _ s: UInt32) {
            a = a &+ I(b, c, d) &+ x &+ 0x50a28be6
            a = ROL(a, s)
        }
        
        // *** The function starts here ***
        
        var (aa, bb, cc, dd) = MDbuf
        var (aaa, bbb, ccc, ddd) = MDbuf
        
        /* round 1 */
        FF(&aa, bb, &cc, dd, X[ 0], 11)
        FF(&dd, aa, &bb, cc, X[ 1], 14)
        FF(&cc, dd, &aa, bb, X[ 2], 15)
        FF(&bb, cc, &dd, aa, X[ 3], 12)
        FF(&aa, bb, &cc, dd, X[ 4],  5)
        FF(&dd, aa, &bb, cc, X[ 5],  8)
        FF(&cc, dd, &aa, bb, X[ 6],  7)
        FF(&bb, cc, &dd, aa, X[ 7],  9)
        FF(&aa, bb, &cc, dd, X[ 8], 11)
        FF(&dd, aa, &bb, cc, X[ 9], 13)
        FF(&cc, dd, &aa, bb, X[10], 14)
        FF(&bb, cc, &dd, aa, X[11], 15)
        FF(&aa, bb, &cc, dd, X[12],  6)
        FF(&dd, aa, &bb, cc, X[13],  7)
        FF(&cc, dd, &aa, bb, X[14],  9)
        FF(&bb, cc, &dd, aa, X[15],  8)
        
        /* round 2 */
        GG(&aa, bb, &cc, dd, X[ 7],  7)
        GG(&dd, aa, &bb, cc, X[ 4],  6)
        GG(&cc, dd, &aa, bb, X[13],  8)
        GG(&bb, cc, &dd, aa, X[ 1], 13)
        GG(&aa, bb, &cc, dd, X[10], 11)
        GG(&dd, aa, &bb, cc, X[ 6],  9)
        GG(&cc, dd, &aa, bb, X[15],  7)
        GG(&bb, cc, &dd, aa, X[ 3], 15)
        GG(&aa, bb, &cc, dd, X[12],  7)
        GG(&dd, aa, &bb, cc, X[ 0], 12)
        GG(&cc, dd, &aa, bb, X[ 9], 15)
        GG(&bb, cc, &dd, aa, X[ 5],  9)
        GG(&aa, bb, &cc, dd, X[ 2], 11)
        GG(&dd, aa, &bb, cc, X[14],  7)
        GG(&cc, dd, &aa, bb, X[11], 13)
        GG(&bb, cc, &dd, aa, X[ 8], 12)
        
        /* round 3 */
        HH(&aa, bb, &cc, dd, X[ 3], 11)
        HH(&dd, aa, &bb, cc, X[10], 13)
        HH(&cc, dd, &aa, bb, X[14],  6)
        HH(&bb, cc, &dd, aa, X[ 4],  7)
        HH(&aa, bb, &cc, dd, X[ 9], 14)
        HH(&dd, aa, &bb, cc, X[15],  9)
        HH(&cc, dd, &aa, bb, X[ 8], 13)
        HH(&bb, cc, &dd, aa, X[ 1], 15)
        HH(&aa, bb, &cc, dd, X[ 2], 14)
        HH(&dd, aa, &bb, cc, X[ 7],  8)
        HH(&cc, dd, &aa, bb, X[ 0], 13)
        HH(&bb, cc, &dd, aa, X[ 6],  6)
        HH(&aa, bb, &cc, dd, X[13],  5)
        HH(&dd, aa, &bb, cc, X[11], 12)
        HH(&cc, dd, &aa, bb, X[ 5],  7)
        HH(&bb, cc, &dd, aa, X[12],  5)
        
        /* round 4 */
        II(&aa, bb, &cc, dd, X[ 1], 11)
        II(&dd, aa, &bb, cc, X[ 9], 12)
        II(&cc, dd, &aa, bb, X[11], 14)
        II(&bb, cc, &dd, aa, X[10], 15)
        II(&aa, bb, &cc, dd, X[ 0], 14)
        II(&dd, aa, &bb, cc, X[ 8], 15)
        II(&cc, dd, &aa, bb, X[12],  9)
        II(&bb, cc, &dd, aa, X[ 4],  8)
        II(&aa, bb, &cc, dd, X[13],  9)
        II(&dd, aa, &bb, cc, X[ 3], 14)
        II(&cc, dd, &aa, bb, X[ 7],  5)
        II(&bb, cc, &dd, aa, X[15],  6)
        II(&aa, bb, &cc, dd, X[14],  8)
        II(&dd, aa, &bb, cc, X[ 5],  6)
        II(&cc, dd, &aa, bb, X[ 6],  5)
        II(&bb, cc, &dd, aa, X[ 2], 12)
        
        
        /* parallel round 1 */
        III(&aaa, bbb, &ccc, ddd, X [ 5],  8)
        III(&ddd, aaa, &bbb, ccc, X[14],  9)
        III(&ccc, ddd, &aaa, bbb, X[ 7],  9)
        III(&bbb, ccc, &ddd, aaa, X[ 0], 11)
        III(&aaa, bbb, &ccc, ddd, X[ 9], 13)
        III(&ddd, aaa, &bbb, ccc, X[ 2], 15)
        III(&ccc, ddd, &aaa, bbb, X[11], 15)
        III(&bbb, ccc, &ddd, aaa, X[ 4],  5)
        III(&aaa, bbb, &ccc, ddd, X[13],  7)
        III(&ddd, aaa, &bbb, ccc, X[ 6],  7)
        III(&ccc, ddd, &aaa, bbb, X[15],  8)
        III(&bbb, ccc, &ddd, aaa, X[ 8], 11)
        III(&aaa, bbb, &ccc, ddd, X[ 1], 14)
        III(&ddd, aaa, &bbb, ccc, X[10], 14)
        III(&ccc, ddd, &aaa, bbb, X[ 3], 12)
        III(&bbb, ccc, &ddd, aaa, X[12],  6)
        
        /* parallel round 2 */
        HHH(&aaa, bbb, &ccc, ddd, X[ 6],  9)
        HHH(&ddd, aaa, &bbb, ccc, X[11], 13)
        HHH(&ccc, ddd, &aaa, bbb, X[ 3], 15)
        HHH(&bbb, ccc, &ddd, aaa, X[ 7],  7)
        HHH(&aaa, bbb, &ccc, ddd, X[ 0], 12)
        HHH(&ddd, aaa, &bbb, ccc, X[13],  8)
        HHH(&ccc, ddd, &aaa, bbb, X[ 5],  9)
        HHH(&bbb, ccc, &ddd, aaa, X[10], 11)
        HHH(&aaa, bbb, &ccc, ddd, X[14],  7)
        HHH(&ddd, aaa, &bbb, ccc, X[15],  7)
        HHH(&ccc, ddd, &aaa, bbb, X[ 8], 12)
        HHH(&bbb, ccc, &ddd, aaa, X[12],  7)
        HHH(&aaa, bbb, &ccc, ddd, X[ 4],  6)
        HHH(&ddd, aaa, &bbb, ccc, X[ 9], 15)
        HHH(&ccc, ddd, &aaa, bbb, X[ 1], 13)
        HHH(&bbb, ccc, &ddd, aaa, X[ 2], 11)
        
        /* parallel round 3 */
        GGG(&aaa, bbb, &ccc, ddd, X[15],  9)
        GGG(&ddd, aaa, &bbb, ccc, X[ 5],  7)
        GGG(&ccc, ddd, &aaa, bbb, X[ 1], 15)
        GGG(&bbb, ccc, &ddd, aaa, X[ 3], 11)
        GGG(&aaa, bbb, &ccc, ddd, X[ 7],  8)
        GGG(&ddd, aaa, &bbb, ccc, X[14],  6)
        GGG(&ccc, ddd, &aaa, bbb, X[ 6],  6)
        GGG(&bbb, ccc, &ddd, aaa, X[ 9], 14)
        GGG(&aaa, bbb, &ccc, ddd, X[11], 12)
        GGG(&ddd, aaa, &bbb, ccc, X[ 8], 13)
        GGG(&ccc, ddd, &aaa, bbb, X[12],  5)
        GGG(&bbb, ccc, &ddd, aaa, X[ 2], 14)
        GGG(&aaa, bbb, &ccc, ddd, X[10], 13)
        GGG(&ddd, aaa, &bbb, ccc, X[ 0], 13)
        GGG(&ccc, ddd, &aaa, bbb, X[ 4],  7)
        GGG(&bbb, ccc, &ddd, aaa, X[13],  5)
        
        /* parallel round 4 */
        FFF(&aaa, bbb, &ccc, ddd, X[ 8], 15)
        FFF(&ddd, aaa, &bbb, ccc, X[ 6],  5)
        FFF(&ccc, ddd, &aaa, bbb, X[ 4],  8)
        FFF(&bbb, ccc, &ddd, aaa, X[ 1], 11)
        FFF(&aaa, bbb, &ccc, ddd, X[ 3], 14)
        FFF(&ddd, aaa, &bbb, ccc, X[11], 14)
        FFF(&ccc, ddd, &aaa, bbb, X[15],  6)
        FFF(&bbb, ccc, &ddd, aaa, X[ 0], 14)
        FFF(&aaa, bbb, &ccc, ddd, X[ 5],  6)
        FFF(&ddd, aaa, &bbb, ccc, X[12],  9)
        FFF(&ccc, ddd, &aaa, bbb, X[ 2], 12)
        FFF(&bbb, ccc, &ddd, aaa, X[13],  9)
        FFF(&aaa, bbb, &ccc, ddd, X[ 9], 12)
        FFF(&ddd, aaa, &bbb, ccc, X[ 7],  5)
        FFF(&ccc, ddd, &aaa, bbb, X[10], 15)
        FFF(&bbb, ccc, &ddd, aaa, X[14],  8)
        
        
        /* combine results */
        MDbuf = (MDbuf.1 &+ cc &+ ddd,
                 MDbuf.2 &+ dd &+ aaa,
                 MDbuf.3 &+ aa &+ bbb,
                 MDbuf.0 &+ bb &+ ccc)
    }
    
    mutating private func update(data: Data) {
        data.withUnsafeBytes { (pointer) -> Void in
            guard var ptr = pointer.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
            var length = data.count
            var X = [UInt32](repeating: 0, count: 16)
            
            // Process remaining bytes from last call:
            if buffer.count > 0 && buffer.count + length >= 64 {
                let amount = 64 - buffer.count
                buffer.append(ptr, count: amount)
                buffer.withUnsafeBytes { _ = memcpy(&X, $0.baseAddress, 64) }
                compress(X)
                ptr += amount
                length -= amount
            }
            // Process 64 byte chunks:
            while length >= 64 {
                memcpy(&X, ptr, 64)
                compress(X)
                ptr += 64
                length -= 64
            }
            // Save remaining unprocessed bytes:
            buffer = Data(bytes: ptr, count: length)
        }
        count += Int64(data.count)
    }
    
    mutating private func finalize() -> Data {
        var X = [UInt32](repeating: 0, count: 16)
        /* append the bit m_n == 1 */
        buffer.append(0x80)
        buffer.withUnsafeBytes { _ = memcpy(&X, $0.baseAddress, buffer.count) }
        
        if (count & 63) > 55 {
            /* length goes to next block */
            compress(X)
            X = [UInt32](repeating: 0, count: 16)
        }
        
        /* append length in bits */
        let lswlen = UInt32(truncatingIfNeeded: count)
        let mswlen = UInt32(UInt64(count) >> 32)
        X[14] = lswlen << 3
        X[15] = (lswlen >> 29) | (mswlen << 3)
        compress(X)
        
        var data = Data(count: 16)
        data.withUnsafeMutableBytes { (pointer) -> Void in
            let ptr = pointer.bindMemory(to: UInt32.self)
            ptr[0] = MDbuf.0
            ptr[1] = MDbuf.1
            ptr[2] = MDbuf.2
            ptr[3] = MDbuf.3
        }
        
        buffer = Data()
        
        return data
    }
}

extension RIPEMD128 {
    static func hash(_ message: Data) -> Data {
        var md = RIPEMD128()
        md.update(data: message)
        return md.finalize()
    }
}

