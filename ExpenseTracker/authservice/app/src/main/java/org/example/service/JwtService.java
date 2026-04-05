package org.example.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class JwtService {
    public static final String SECRET = "9F4C2D7E8B1A6C5F3E2D9A4B7C8E1F6035B6D1A9C2E4F7B8D3A6C9E1F2B4D7A";

    public String extractUsername(String token)
    {
        return extractClaim(token, Claims::getSubject);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimResolver)
    {
        final Claims claims = extractAllClaims(token);
        return claimResolver.apply(claims);
    }

    public Date extractExpiration(String token)
    {
        return extractClaim(token, Claims::getExpiration);
    }

    private Boolean isTokenExpired(String token)
    {
        return extractExpiration(token).before(new Date());
    }

    public Boolean validateToken(String token, UserDetails userDetails)
    {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }

    public String GenerateToken(String username){
        Map<String, Object> claims = new HashMap<>();
        return createToken(claims, username);
    }

    private String createToken(Map<String, Object> claims, String username)
    {
        return Jwts.builder().setClaims(claims).setSubject(username).setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 15)).signWith(getSignKey(), SignatureAlgorithm.HS256).compact();
    }

    private Claims extractAllClaims(String token)
    {
        return Jwts.parser().setSigningKey(getSignKey()).build().parseClaimsJws(token).getBody();
    }

    private Key getSignKey()
    {
        byte[] keyBytes = Decoders.BASE64.decode(SECRET);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
