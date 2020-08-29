using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class BufFixLevel2 : MonoBehaviour
{
    // Start is called before the first frame update

    private void Awake() {
        int numScenePersist = FindObjectsOfType<BufFixLevel2>().Length;

        if (numScenePersist > 1) {
            Destroy(gameObject);
            Debug.Log("destroying scene persistent!");
        }

        else {
            DontDestroyOnLoad(this.gameObject);
            Debug.Log("don t destroying scene persistent!");
        }
    }


    void Start()
    {

        if (SceneManager.GetActiveScene().buildIndex == 3) {
            SceneManager.LoadScene(3);

        }

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
