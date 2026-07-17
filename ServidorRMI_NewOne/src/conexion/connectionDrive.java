package conexion;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

public class connectionDrive {

    private static final String PU_NAME = "Grupo05_DDA_PAF";
    private static EntityManagerFactory emf;

    public static EntityManager getEntityManager() {
        if (emf == null) {
            try {
                emf = Persistence.createEntityManagerFactory(PU_NAME);
            } catch (Exception e) {
                System.err.println("¡ERROR FATAL AL INICIAR JPA! " + e.getMessage());
                throw new RuntimeException("Error al iniciar JPA: " + e.getMessage());
            }
        }
        return emf.createEntityManager();
    }

    public static void close() {
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }
}