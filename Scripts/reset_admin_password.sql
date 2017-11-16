UPDATE 
    [aspnet_Membership] 
SET 
    [Password]='qOvF8m8F2IcWMvfOBjJYHmfLABc=', 
    [PasswordSalt]='OM5gu45RQuJ76itRvkSPFw==', 
    [IsApproved] = '1', 
    [IsLockedOut] = '0'
WHERE 
    UserId IN (
        SELECT UserId FROM dbo.aspnet_Users WHERE UserName = 'sitecore\Admin'
    ) 