require './RPNConverter.rb'

def getDelta(pila)
	estados = Array.new(2) {-1} # Estado Inicial[0] y Estado Final [1]
	if !pila.empty?
		char = pila.pop # Saco el siguiente elemento de la pila
		if char.match /\d/ # Si es un número (Parte del alfabeto)
			estados[0] = $contEstados
			$contEstados += 1
			($delta[char.to_i][estados[0]]).push($contEstados)
			estados[1] = $contEstados
			$contEstados+= 1
			return estados

		elsif char == "*" # Si es Kleene Star
			# Creamos los nuevos estados
			inicial = $contEstados
			$contEstados += 1
			final = $contEstados
			$contEstados += 1
			# Solo un operando y obtenemos su estado inicial y final
			estadosOperando =  getDelta(pila)
			# Agregamos las transiciones correspondientes a delta de acuerdo con el algoritmo de Thompson
			($delta[$posEpsilon][inicial]).push(estadosOperando[0])
			($delta[$posEpsilon][inicial]).push(final)
			($delta[$posEpsilon][estadosOperando[1]]).push(estadosOperando[0])
			($delta[$posEpsilon][estadosOperando[1]]).push(final)
			# Asignamos los estados inicial y final del autómata resultante
			estados[0] = inicial
			estados[1] = final
			return estados

		elsif char == "+" # Si es Kleene Star sin null
			# Creamos los nuevos estados
			inicial = $contEstados
			$contEstados += 1
			final = $contEstados
			$contEstados += 1
			# Solo un operando y obtenemos su estado inicial y final
			estadosOperando =  getDelta(pila)
			# Agregamos las transiciones correspondientes a delta de acuerdo con el algoritmo de Thompson
			($delta[$posEpsilon][inicial]).push(estadosOperando[0])
			($delta[$posEpsilon][estadosOperando[1]]).push(estadosOperando[0])
			($delta[$posEpsilon][estadosOperando[1]]).push(final)
			# Asignamos los estados inicial y final del autómata resultante
			estados[0] = inicial
			estados[1] = final
			return estados
		

		elsif char == "|" # Si es Unión
			# Dos operandos y obtenemos sus estados inicial y final
			estadosOperando1 = getDelta(pila)
			estadosOperando2 = getDelta(pila)
			# Creamos los nuevos estados
			inicial = $contEstados
			$contEstados += 1
			final = $contEstados
			$contEstados += 1
			# Agregamos las transiciones correspondientes a delta de acuerdo con el algoritmo de Thompson
			($delta[$posEpsilon][inicial]).push(estadosOperando1[0])
			($delta[$posEpsilon][inicial]).push(estadosOperando2[0])
			($delta[$posEpsilon][estadosOperando1[1]]).push(final)
			($delta[$posEpsilon][estadosOperando2[1]]).push(final)
			# Asignamos los estados inicial y final del autómata resultante
			estados[0] = inicial
			estados[1] = final
			return estados

		elsif char == "." # Si es concatenación *Nota: No se crean nuevos estados.*
			# Dos operandos y obtenemos sus estados inicial y final
			estadosOperando1 = getDelta(pila)
			estadosOperando2 = getDelta(pila)
			# Agregamos las transiciones correspondientes a delta de acuerdo con el algoritmo de Thompson
			($delta[$posEpsilon][estadosOperando2[1]]).push(estadosOperando1[0])
			# Asignamos los estados inicial y final del autómata resultante
			estados[0] = estadosOperando2[0]
			estados[1] = estadosOperando1[1]
			return estados

		end
	end
end

# Main

convertidor = RPNConverter.new()
puts "Kleene Star'*'\nKlenne Star sin null '+'\nUnion '|'\nConcatenacion '.'"
puts "Escribe expresión regular"
regex = gets.chomp
#regex = "0.1*|1" # Caso prueba

# Obtenemos la expresión regular convertida a notación polaca inversa
pila = convertidor.infix_to_rpn(regex)
# Sacar número de estados
$estados = 0
pila.each do |c|
	if c != "."		# Evitamos el '.' ya que no genera un estado extra
		$estados += 1
	end
end
$estados*=2			# Multiplicamos por 2 ya que cada operación genera 2 estados extra
# Determinar alfabeto para obtener delta
$alfabeto = Array("0".."9") # Del 0 al 9

# Establecemos que la posición de las transiciones Epsilon dentro de delta, seran la última columna
$posEpsilon = $alfabeto.size

# Inicializar Delta
	# Se guarda cada estado compuesto en un arreglo. Ej. Estado 2,1 => [2,1]
$delta = Array.new(($alfabeto.size) + 1) {Array.new($estados){Array.new()}} # De tamaño: número de objetos en alfabeto + 1 (por epsilon-moves) x número de estados

# Obtenemos el estado inicial y final y la delta construida
# pasando como parámetro la pila de notación polaca inversa
$contEstados = 0 # Contador para generar nuevos estados
#binding.pry
estadoInicialFinal = getDelta(pila)
# Imprime estado inicial y final

puts "Estado Inicial => #{estadoInicialFinal.at(0)}"
puts "Estado Final => #{estadoInicialFinal.at(1)}"

# Imprime Delta
print "\t"
	for x in 0...($alfabeto.size + 1)
		if x == $alfabeto.size
			print "epsilon\t"
		else
			print x,"\t"
		end
	end
	puts ""
	for i in 0...$estados
		print "q#{i}","\t"
		for j in 0...($alfabeto.size+1)
			if ($delta[j][i]).size != 0
				$delta[j][i].each do |q|
					print "q#{q},"
				end
				print "\t"
			else
				print "NULL","\t"
			end
		end
		puts ""
	end
















