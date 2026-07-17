import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import Interfaces.IGestionClientesRemoto;
import entidades.Clientes;
import java.util.List;

public class TestRMI {
    public static void main(String[] args) {
        try {
            Registry registry = LocateRegistry.getRegistry("127.0.0.1", 3239);
            IGestionClientesRemoto clienteRMI = (IGestionClientesRemoto) registry.lookup("clienteServicio");
            
            List<Clientes> lista = clienteRMI.listarClientes();
            for (Clientes c : lista) {
                System.out.println("ID: " + c.getIdCliente() + ", Email: '" + c.getEmail() + "', Pass: '" + c.getPassword() + "'");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
