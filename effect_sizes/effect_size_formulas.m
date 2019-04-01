        d2r = @(d) d ./ (d.^2 + 4).^.5;                 % convert d to r
        r2d = @(r) 2*r ./ (1 - r.^2).^.5;               % convert r to d
        
        t2r = @(t, df) t ./ (t.^2 + df).^.5;            % t-value to r   
        r2t = @(r, n) (r.*sqrt(n-2))./(sqrt(1-r.^2));   % ***
        
        t2d = @(t, df) 2 .* t ./ sqrt(df);               % t-value to d, 2-group case
        d2t = @(d, df) d .* sqrt(df) ./ 2;               % d-value to t, 2-group case 
        