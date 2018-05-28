BEGIN
	DECLARE @nro_interno INT			,
			  @cod_empresa INT			,
			  @mes VARCHAR(24)			,
			  @ano NUMERIC(4,0)			,
			  @nome_contrato VARCHAR(64),
			  @STR VARCHAR(8000)
	
	SET @STR = ''
	
	SET @cod_empresa = 5;
	
	DECLARE C_PIVOT CURSOR FOR SELECT
									c.nro_interno,
									LEFT( RIGHT('000'+CAST(c.nro_interno AS VARCHAR(10)),3) + '-' +RTRIM( LTRIM( UPPER( c.nome_contrato ) ) ), 20) AS nome_contrato
								FROM 
									contratos c
								WHERE 
									c.cod_empresa = @cod_empresa
									AND c.nro_interno IN( 3 )
								ORDER BY c.nro_interno
	
	OPEN C_PIVOT 
	FETCH NEXT FROM C_PIVOT INTO 	@nro_interno, 
								 			@nome_contrato

	WHILE @@FETCH_STATUS = 0
	BEGIN		
		SET @STR = @STR
				  + CHAR(44) + CHAR(39) + @nome_contrato + CHAR(39)
				  + ' = (SELECT'
				  + ' 		((SUM(am.vlr_nf) * 100) / (SELECT TOP 1 '
				  + ' 												percentual '
				  + ' 											FROM '
				  + ' 												impostos_contrato ic '
				  + ' 											WHERE '
				  + ' 												ic.nro_interno = mc.nro_interno'
				  + ' 										   	AND ic.cod_empresa = mc.cod_empresa)) AS vlr_nf'
				  + ' FROM '
				  + ' 	medicao_contrato mc 	'
				  + ' INNER JOIN anexos_medicao am '
				  + ' 	ON mc.cod_interno = am.cod_interno'
				  + ' WHERE  '
				  + ' 	UPPER( am.tipo ) = '+ CHAR(39)+'NF'+CHAR(39)
				  + ' 	AND mc.cod_empresa = '+ CAST(@cod_empresa AS VARCHAR(5))
				  + ' 	AND mc.nro_interno = '+ CAST(@nro_interno AS VARCHAR(5))
				  + ' 	AND MONTH( am.data_emissao_nf ) = rs.mes'
				  + ' 	AND YEAR( am.data_emissao_nf ) = rs.ano'
				  + ' GROUP BY '
				  + ' 	mc.nro_interno,'
				  + ' 	mc.cod_empresa)'				  

	
		FETCH NEXT FROM C_PIVOT INTO @nro_interno	 , 
									 		  @nome_contrato
	END
		
	CLOSE C_PIVOT;
	DEALLOCATE C_PIVOT;	

	SET @STR = ' SELECT '
				+' rs.ano, '
				+'rs.MES   '
				+' FROM '
				+' ( '
				+' 	SELECT DISTINCT '
				+'   		YEAR(am2.data_emissao_nf) AS ano,'
				+'			CASE MONTH(am2.data_emissao_nf) '
				+'          WHEN 1 THEN '+CHAR(39)+'JANEIRO'+CHAR(39)
				+'          WHEN 2 THEN '+CHAR(39)+'FEVEREIRO'+CHAR(39)
				+'          WHEN 3 THEN '+CHAR(39)+'MARÇO'+CHAR(39)
				+'          WHEN 4 THEN '+CHAR(39)+'ABRIL'+CHAR(39)
				+'          WHEN 5 THEN '+CHAR(39)+'MAIO'+CHAR(39)
				+'          WHEN 6 THEN '+CHAR(39)+'JUNHO'+CHAR(39)
				+'          WHEN 7 THEN '+CHAR(39)+'JULHO'+CHAR(39)
				+'          WHEN 8 THEN '+CHAR(39)+'AGOSTO'+CHAR(39)
				+'          WHEN 9 THEN '+CHAR(39)+'SETEMBRO'+CHAR(39)
				+'          WHEN 10 THEN '+CHAR(39)+'OUTUBRO'+CHAR(39)
				+'          WHEN 11 THEN '+CHAR(39)+'NOVEMBRO'+CHAR(39)
				+'          WHEN 12 THEN '+CHAR(39)+'DEZEMBRO'+CHAR(39)
				+'	  	   END AS MES'
				+'		FROM '
				+'     		medicao_contrato mc	'
				+' 		INNER JOIN anexos_medicao am2 '
				+'			ON mc.cod_interno = am2.cod_interno	'
				+'		WHERE '  				
				+'			UPPER( am2.tipo ) ='+ CHAR(39) +'NF'+ CHAR(39)
				+' 			AND mc.cod_empresa = '+CAST(@cod_empresa AS VARCHAR(5))
				+' ) AS rs'
				+'ORDER BY	'
				+' rs.ano,'
				+' rs.mes'				 

	EXEC( @STR )

END

SELECT
	YEAR(am.data_emissao_nf) AS ano,
	MONTH(am.data_emissao_nf) AS mes
FROM 
	medicao_contrato mc 	
INNER JOIN anexos_medicao am 
	ON mc.cod_interno = am.cod_interno
WHERE  
	1 = 1
	AND UPPER( am.tipo ) = 'NF'
	AND mc.cod_empresa = 5
	AND mc.nro_interno = 3	
